package com.warehouse.service;

import com.warehouse.entity.Goods;
import com.warehouse.repository.GoodsRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 商品基础信息维护。库存变动统一走 {@link StockService}，这里不再提供改库存的方法。
 */
@Service
public class GoodsService {
    private final GoodsRepository goodsRepository;

    public GoodsService(GoodsRepository goodsRepository) {
        this.goodsRepository = goodsRepository;
    }

    /**
     * 列表可见范围：{@code null} 表示全部（管理员/只读）；空串表示未绑定仓库、看不到数据；
     * 否则只返回该仓库的商品。仓库员的数据隔离在这里生效，而不是只靠前端过滤。
     */
    public List<Goods> getGoods(String warehouseScope) {
        if (warehouseScope == null) {
            return goodsRepository.findAllByOrderByIdDesc();
        }
        if (warehouseScope.isBlank()) {
            return List.of();
        }
        return goodsRepository.findAllByWarehouseOrderByIdDesc(warehouseScope);
    }

    @Transactional
    public Goods saveGoods(Goods goods) {
        if (goods.getId() == null) {
            goods.setCreateTime(LocalDateTime.now());
            if (goods.getCurrentStock() == null) goods.setCurrentStock(0);
        }
        goods.setUpdateTime(LocalDateTime.now());
        return goodsRepository.save(goods);
    }

    @Transactional
    public void deleteGoods(Long id) {
        goodsRepository.deleteById(id);
    }

    public int getTotalStock() {
        return goodsRepository.findAll().stream()
                .mapToInt(g -> intValue(g.getCurrentStock()))
                .sum();
    }

    public int getLowStockSkuCount() {
        return (int) goodsRepository.findAll().stream()
                .filter(g -> intValue(g.getCurrentStock()) < intValue(g.getMinStock()))
                .count();
    }

    private static int intValue(Integer value) {
        return value == null ? 0 : value;
    }
}
