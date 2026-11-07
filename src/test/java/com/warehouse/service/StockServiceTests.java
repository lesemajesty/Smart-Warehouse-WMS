package com.warehouse.service;

import com.warehouse.entity.Goods;
import com.warehouse.entity.InboundOrder;
import com.warehouse.entity.OutboundOrder;
import com.warehouse.exception.BusinessException;
import com.warehouse.repository.GoodsRepository;
import com.warehouse.repository.InboundRecordRepository;
import com.warehouse.repository.OutboundOrderRepository;
import com.warehouse.repository.OutboundRecordRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * 库存事务的核心行为：单据、流水、库存、月统计必须同进同退。
 * 使用测试库（H2），每个用例结束后回滚。
 */
@SpringBootTest
@Transactional
class StockServiceTests {

    @Autowired private StockService stockService;
    @Autowired private GoodsRepository goodsRepository;
    @Autowired private OutboundOrderRepository outboundOrderRepository;
    @Autowired private OutboundRecordRepository outboundRecordRepository;
    @Autowired private InboundRecordRepository inboundRecordRepository;

    private Goods newGoods(String code, int stock) {
        Goods goods = new Goods();
        goods.setCode(code);
        goods.setName("测试商品-" + code);
        goods.setWarehouse("测试仓");
        goods.setCurrentStock(stock);
        goods.setMinStock(2);
        goods.setMaxStock(100);
        goods.setCreateTime(LocalDateTime.now());
        return goodsRepository.save(goods);
    }

    @Test
    void shipDeductsStockAndWritesBothLedgers() {
        Goods goods = newGoods("T-SHIP-1", 10);

        OutboundOrder order = stockService.ship(goods.getId(), 4, "tester", "OUT-T-1");

        assertThat(order.getOrderNo()).isEqualTo("OUT-T-1");
        assertThat(order.getGoodsName()).isEqualTo(goods.getName());
        assertThat(stockOf(goods)).isEqualTo(6);
        assertThat(outboundOrderRepository.findAll())
                .anyMatch(o -> "OUT-T-1".equals(o.getOrderNo()));
        assertThat(outboundRecordRepository.findAll())
                .anyMatch(r -> goods.getId().equals(r.getGoodsId()) && r.getQuantity() == 4);
    }

    @Test
    void shipRejectsOverdrawAndLeavesNothingBehind() {
        Goods goods = newGoods("T-SHIP-2", 3);

        assertThatThrownBy(() -> stockService.ship(goods.getId(), 5, "tester", "OUT-T-2"))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("库存不足");

        assertThat(stockOf(goods)).isEqualTo(3);
        assertThat(outboundOrderRepository.findAll())
                .noneMatch(o -> "OUT-T-2".equals(o.getOrderNo()));
        assertThat(outboundRecordRepository.findAll())
                .noneMatch(r -> goods.getId().equals(r.getGoodsId()));
    }

    @Test
    void adjustRejectsOverdraw() {
        Goods goods = newGoods("T-ADJ-1", 1);

        assertThatThrownBy(() -> stockService.adjust(goods.getId(), -2, "tester"))
                .isInstanceOf(BusinessException.class);

        assertThat(stockOf(goods)).isEqualTo(1);
    }

    @Test
    void receiveAddsStockAndWritesRecord() {
        Goods goods = newGoods("T-REC-1", 0);

        InboundOrder order = stockService.receive(goods.getId(), 7, "tester", "IN-T-1");

        assertThat(order.getOrderNo()).isEqualTo("IN-T-1");
        assertThat(stockOf(goods)).isEqualTo(7);
        assertThat(inboundRecordRepository.findAll())
                .anyMatch(r -> goods.getId().equals(r.getGoodsId()) && r.getQuantity() == 7);
    }

    private int stockOf(Goods goods) {
        return goodsRepository.findById(goods.getId()).orElseThrow().getCurrentStock();
    }
}
