package com.warehouse.controller;

import com.warehouse.entity.Goods;
import com.warehouse.exception.BusinessException;
import com.warehouse.service.GoodsService;
import com.warehouse.service.OperationLogService;
import com.warehouse.service.StockService;
import com.warehouse.service.WarehouseScopeService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/goods")
public class GoodsController {

    private final GoodsService goodsService;
    private final StockService stockService;
    private final WarehouseScopeService warehouseScopeService;
    private final OperationLogService operationLogService;

    public GoodsController(GoodsService goodsService, StockService stockService,
                           WarehouseScopeService warehouseScopeService,
                           OperationLogService operationLogService) {
        this.goodsService = goodsService;
        this.stockService = stockService;
        this.warehouseScopeService = warehouseScopeService;
        this.operationLogService = operationLogService;
    }

    /** 列表按仓库隔离：管理员/只读看全部，仓库员只看绑定仓库 */
    @GetMapping
    public ResponseEntity<List<Goods>> getAllGoods(Authentication authentication) {
        String scope = warehouseScopeService.scope(authentication);
        return ResponseEntity.ok(goodsService.getGoods(scope));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Goods> saveGoods(@RequestBody Goods goods) {
        if (goods.getCode() == null || goods.getCode().isBlank()) {
            throw new BusinessException("货物编码不能为空");
        }
        if (goods.getName() == null || goods.getName().isBlank()) {
            throw new BusinessException("货物名称不能为空");
        }
        if (goods.getWarehouse() == null || goods.getWarehouse().isBlank()) {
            throw new BusinessException("仓库不能为空");
        }
        Goods saved = goodsService.saveGoods(goods);
        operationLogService.log("保存商品", "goods", saved.getId(),
                "编码 " + saved.getCode() + " / " + saved.getName() + "，库存 " + saved.getCurrentStock());
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteGoods(@PathVariable Long id) {
        goodsService.deleteGoods(id);
        operationLogService.log("删除商品", "goods", id, "删除商品 ID " + id);
        return ResponseEntity.ok().build();
    }

    /**
     * 商品页的加减库存。库存、流水、月统计在同一事务内完成；
     * 超量扣减返回 400，不再把库存静默截断为 0。
     */
    @PostMapping("/{id}/stock")
    @PreAuthorize("hasAnyRole('ADMIN', 'WAREHOUSE')")
    public ResponseEntity<Goods> updateStock(@PathVariable Long id, @RequestBody Map<String, Integer> payload,
                                             Authentication authentication) {
        Integer delta = payload.get("delta");
        if (delta == null) {
            throw new BusinessException("缺少 delta 参数");
        }
        String scope = warehouseScopeService.requireOperable(authentication);
        Goods updated = stockService.adjust(id, delta, authentication.getName(), scope);
        operationLogService.log("调整库存", "goods", id,
                "调整 " + delta + "，结果库存 " + updated.getCurrentStock(), updated.getWarehouse());
        return ResponseEntity.ok(updated);
    }
}
