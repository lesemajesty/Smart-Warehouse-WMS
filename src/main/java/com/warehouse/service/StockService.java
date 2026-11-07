package com.warehouse.service;

import com.warehouse.entity.Goods;
import com.warehouse.entity.InboundOrder;
import com.warehouse.entity.InboundRecord;
import com.warehouse.entity.OutboundOrder;
import com.warehouse.entity.OutboundRecord;
import com.warehouse.exception.BusinessException;
import com.warehouse.exception.WarehouseAccessException;
import com.warehouse.repository.GoodsRepository;
import com.warehouse.repository.InboundOrderRepository;
import com.warehouse.repository.InboundRecordRepository;
import com.warehouse.repository.OutboundOrderRepository;
import com.warehouse.repository.OutboundRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 库存变动唯一入口。
 * <p>
 * 一次变动涉及「库存 / 单据 / 流水 / 月统计」四处写入，全部放在同一个事务里，
 * 任何一步失败都整体回滚，避免账实不符。
 */
@Service
public class StockService {

    private static final DateTimeFormatter NO_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");

    private final GoodsRepository goodsRepository;
    private final InboundOrderRepository inboundOrderRepository;
    private final OutboundOrderRepository outboundOrderRepository;
    private final InboundRecordRepository inboundRecordRepository;
    private final OutboundRecordRepository outboundRecordRepository;
    private final StatisticsService statisticsService;

    public StockService(GoodsRepository goodsRepository,
                        InboundOrderRepository inboundOrderRepository,
                        OutboundOrderRepository outboundOrderRepository,
                        InboundRecordRepository inboundRecordRepository,
                        OutboundRecordRepository outboundRecordRepository,
                        StatisticsService statisticsService) {
        this.goodsRepository = goodsRepository;
        this.inboundOrderRepository = inboundOrderRepository;
        this.outboundOrderRepository = outboundOrderRepository;
        this.inboundRecordRepository = inboundRecordRepository;
        this.outboundRecordRepository = outboundRecordRepository;
        this.statisticsService = statisticsService;
    }

    /** 入库：建入库单 + 入库流水 + 加库存 + 月统计 */
    @Transactional
    public InboundOrder receive(Long goodsId, Integer quantity, String operator, String orderNo) {
        return receive(goodsId, quantity, operator, orderNo, null);
    }

    /** 入库，warehouseScope 为 null 表示不限仓库（管理员）；否则必须是商品所在仓库 */
    @Transactional
    public InboundOrder receive(Long goodsId, Integer quantity, String operator, String orderNo,
                                String warehouseScope) {
        Goods goods = lockGoods(goodsId);
        assertWarehouse(goods, warehouseScope);
        int qty = requireQuantity(quantity);
        LocalDateTime now = LocalDateTime.now();

        goods.setCurrentStock(stockOf(goods) + qty);
        goods.setUpdateTime(now);
        goodsRepository.save(goods);

        InboundOrder order = new InboundOrder();
        order.setOrderNo(normalizeOrderNo(orderNo, "IN", now));
        order.setGoodsId(goods.getId());
        order.setGoodsName(goods.getName());
        order.setWarehouse(goods.getWarehouse());
        order.setQuantity(qty);
        order.setInboundTime(now);
        order.setOperator(normalizeOperator(operator));
        inboundOrderRepository.save(order);

        InboundRecord record = new InboundRecord();
        record.setGoodsId(goods.getId());
        record.setWarehouse(goods.getWarehouse());
        record.setQuantity(qty);
        record.setInTime(now);
        record.setOperator(order.getOperator());
        inboundRecordRepository.save(record);

        statisticsService.addInbound(qty);
        return order;
    }

    /** 出库：建出库单 + 出库流水 + 减库存 + 月统计；库存不足直接拒绝 */
    @Transactional
    public OutboundOrder ship(Long goodsId, Integer quantity, String operator, String orderNo) {
        return ship(goodsId, quantity, operator, orderNo, null);
    }

    /** 出库，warehouseScope 为 null 表示不限仓库（管理员）；否则必须是商品所在仓库 */
    @Transactional
    public OutboundOrder ship(Long goodsId, Integer quantity, String operator, String orderNo,
                              String warehouseScope) {
        Goods goods = lockGoods(goodsId);
        assertWarehouse(goods, warehouseScope);
        int qty = requireQuantity(quantity);
        int stock = stockOf(goods);
        if (stock < qty) {
            throw new BusinessException("库存不足：当前库存 " + stock + "，本次出库 " + qty);
        }

        LocalDateTime now = LocalDateTime.now();
        goods.setCurrentStock(stock - qty);
        goods.setUpdateTime(now);
        goodsRepository.save(goods);

        OutboundOrder order = new OutboundOrder();
        order.setOrderNo(normalizeOrderNo(orderNo, "OUT", now));
        order.setGoodsId(goods.getId());
        order.setGoodsName(goods.getName());
        order.setWarehouse(goods.getWarehouse());
        order.setQuantity(qty);
        order.setOutboundTime(now);
        order.setOperator(normalizeOperator(operator));
        outboundOrderRepository.save(order);

        OutboundRecord record = new OutboundRecord();
        record.setGoodsId(goods.getId());
        record.setWarehouse(goods.getWarehouse());
        record.setQuantity(qty);
        record.setOutTime(now);
        record.setOperator(order.getOperator());
        outboundRecordRepository.save(record);

        statisticsService.addOutbound(qty);
        return order;
    }

    /**
     * 商品页的加减库存：只记流水，不生成出入库单（属于库存修正）。
     * 超减会抛业务异常，不再静默截断为 0。
     */
    @Transactional
    public Goods adjust(Long goodsId, Integer delta, String operator) {
        return adjust(goodsId, delta, operator, null);
    }

    /**
     * 商品页的加减库存，warehouseScope 规则同入库。
     */
    @Transactional
    public Goods adjust(Long goodsId, Integer delta, String operator, String warehouseScope) {
        if (delta == null || delta == 0) {
            throw new BusinessException("调整数量不能为 0");
        }
        Goods goods = lockGoods(goodsId);
        assertWarehouse(goods, warehouseScope);
        int stock = stockOf(goods);
        int after = stock + delta;
        if (after < 0) {
            throw new BusinessException("库存不足：当前库存 " + stock + "，本次调整 " + delta);
        }

        LocalDateTime now = LocalDateTime.now();
        goods.setCurrentStock(after);
        goods.setUpdateTime(now);
        goodsRepository.save(goods);

        String op = normalizeOperator(operator);
        if (delta > 0) {
            InboundRecord record = new InboundRecord();
            record.setGoodsId(goods.getId());
            record.setWarehouse(goods.getWarehouse());
            record.setQuantity(delta);
            record.setInTime(now);
            record.setOperator(op);
            inboundRecordRepository.save(record);
            statisticsService.addInbound(delta);
        } else {
            OutboundRecord record = new OutboundRecord();
            record.setGoodsId(goods.getId());
            record.setWarehouse(goods.getWarehouse());
            record.setQuantity(-delta);
            record.setOutTime(now);
            record.setOperator(op);
            outboundRecordRepository.save(record);
            statisticsService.addOutbound(-delta);
        }
        return goods;
    }

    private void assertWarehouse(Goods goods, String warehouseScope) {
        if (warehouseScope == null) {
            return;
        }
        if (warehouseScope.isBlank()) {
            throw new WarehouseAccessException("当前账号尚未绑定仓库，请联系管理员");
        }
        if (!warehouseScope.equals(goods.getWarehouse())) {
            throw new WarehouseAccessException("该商品属于「" + goods.getWarehouse()
                    + "」，你绑定的仓库是「" + warehouseScope + "」，不能跨仓操作");
        }
    }

    private Goods lockGoods(Long goodsId) {
        if (goodsId == null) {
            throw new BusinessException("缺少商品 ID");
        }
        return goodsRepository.findByIdForUpdate(goodsId)
                .orElseThrow(() -> new BusinessException("商品不存在：id=" + goodsId));
    }

    private int requireQuantity(Integer quantity) {
        if (quantity == null || quantity <= 0) {
            throw new BusinessException("数量必须大于 0");
        }
        return quantity;
    }

    private int stockOf(Goods goods) {
        return goods.getCurrentStock() == null ? 0 : goods.getCurrentStock();
    }

    private String normalizeOperator(String operator) {
        return operator == null || operator.isBlank() ? "admin" : operator;
    }

    private String normalizeOrderNo(String orderNo, String prefix, LocalDateTime now) {
        return orderNo == null || orderNo.isBlank()
                ? prefix + "-" + now.format(NO_FORMAT)
                : orderNo;
    }
}
