package com.warehouse.service;

import com.warehouse.entity.Goods;
import com.warehouse.entity.WarningRecord;
import com.warehouse.exception.WarehouseAccessException;
import com.warehouse.repository.GoodsRepository;
import com.warehouse.repository.WarningRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class WarningService {
    private final WarningRecordRepository warningRecordRepository;
    private final GoodsRepository goodsRepository;

    public WarningService(WarningRecordRepository warningRecordRepository, GoodsRepository goodsRepository) {
        this.warningRecordRepository = warningRecordRepository;
        this.goodsRepository = goodsRepository;
    }

    /** warehouseScope 为 null 表示全部仓库（管理员/只读）；否则只看该仓库 */
    public List<WarningRecord> getWarnings(String warehouseScope) {
        if (warehouseScope == null) {
            return warningRecordRepository.findAllByOrderByCreateTimeDesc();
        }
        return warningRecordRepository.findAllByWarehouseOrderByCreateTimeDesc(warehouseScope);
    }

    /** 预警总数（含已处理）；warehouseScope 为 null 表示全部仓库 */
    public long countAllWarnings(String warehouseScope) {
        if (warehouseScope == null) {
            return warningRecordRepository.count();
        }
        if (warehouseScope.isBlank()) {
            return 0;
        }
        return warningRecordRepository.countByWarehouse(warehouseScope);
    }

    /** 未处理预警数；warehouseScope 为 null 表示全部仓库 */
    public long countPendingWarnings(String warehouseScope) {
        if (warehouseScope == null) {
            return warningRecordRepository.countByStatus("未处理");
        }
        if (warehouseScope.isBlank()) {
            return 0;
        }
        return warningRecordRepository.countByStatusAndWarehouse("未处理", warehouseScope);
    }

    /**
     * 重算预警：管理员重算全部；仓库员只重算自己仓库，其他仓的预警保持不变。
     */
    @Transactional
    public void manualCheckWarnings(String warehouseScope) {
        List<Goods> goodsList;
        if (warehouseScope == null) {
            warningRecordRepository.deleteByStatus("未处理");
            goodsList = goodsRepository.findAll();
        } else {
            if (warehouseScope.isBlank()) {
                throw new WarehouseAccessException("当前账号尚未绑定仓库，请联系管理员");
            }
            warningRecordRepository.deleteByStatusAndWarehouse("未处理", warehouseScope);
            goodsList = goodsRepository.findAll().stream()
                    .filter(g -> warehouseScope.equals(g.getWarehouse()))
                    .toList();
        }

        LocalDateTime now = LocalDateTime.now();
        for (Goods goods : goodsList) {
            String warningType = null;
            if (goods.getCurrentStock() < goods.getMinStock()) {
                warningType = "低库存预警";
            } else if (goods.getCurrentStock() > goods.getMaxStock()) {
                warningType = "高库存预警";
            }

            if (warningType != null) {
                // 同一商品同一类型只保留最新一条：把之前（含已处理）的同名记录替换掉，
                // 否则每点一次「手动检查」就会多出一行重复历史。
                warningRecordRepository.deleteByGoodsIdAndWarningType(goods.getId(), warningType);

                WarningRecord record = new WarningRecord();
                record.setGoodsId(goods.getId());
                record.setGoodsName(goods.getName());
                record.setGoodsCode(goods.getCode());
                record.setWarehouse(goods.getWarehouse());
                record.setCurrentStock(goods.getCurrentStock());
                record.setMinStock(goods.getMinStock());
                record.setMaxStock(goods.getMaxStock());
                record.setWarningType(warningType);
                record.setStatus("未处理");
                record.setCreateTime(now);
                warningRecordRepository.save(record);
            }
        }
    }

    /** 仓库员只能处理自己仓库的预警 */
    @Transactional
    public void processWarning(Long id, String warehouseScope) {
        WarningRecord record = warningRecordRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("预警记录不存在"));
        if (warehouseScope != null) {
            if (warehouseScope.isBlank()) {
                throw new WarehouseAccessException("当前账号尚未绑定仓库，请联系管理员");
            }
            if (!warehouseScope.equals(record.getWarehouse())) {
                throw new WarehouseAccessException("该预警属于「" + record.getWarehouse()
                        + "」，你绑定的仓库是「" + warehouseScope + "」，不能处理");
            }
        }
        record.setStatus("已处理");
        warningRecordRepository.save(record);
    }
}