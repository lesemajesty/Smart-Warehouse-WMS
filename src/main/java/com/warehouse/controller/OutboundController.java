package com.warehouse.controller;

import com.warehouse.entity.OutboundOrder;
import com.warehouse.repository.OutboundOrderRepository;
import com.warehouse.service.OperationLogService;
import com.warehouse.service.StockService;
import com.warehouse.service.WarehouseScopeService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/outbound")
public class OutboundController {

    private final OutboundOrderRepository outboundRepository;
    private final StockService stockService;
    private final WarehouseScopeService warehouseScopeService;
    private final OperationLogService operationLogService;

    public OutboundController(OutboundOrderRepository outboundRepository, StockService stockService,
                              WarehouseScopeService warehouseScopeService,
                              OperationLogService operationLogService) {
        this.outboundRepository = outboundRepository;
        this.stockService = stockService;
        this.warehouseScopeService = warehouseScopeService;
        this.operationLogService = operationLogService;
    }

    @GetMapping
    public List<OutboundOrder> list(Authentication authentication) {
        String scope = warehouseScopeService.scope(authentication);
        if (scope == null) {
            return outboundRepository.findAllByOrderByOutboundTimeDesc();
        }
        return outboundRepository.findAllByWarehouseOrderByOutboundTimeDesc(scope);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'WAREHOUSE')")
    public ResponseEntity<OutboundOrder> create(@RequestBody OutboundOrder order, Authentication authentication) {
        String scope = warehouseScopeService.requireOperable(authentication);
        OutboundOrder saved = stockService.ship(
                order.getGoodsId(), order.getQuantity(), authentication.getName(), order.getOrderNo(), scope);
        operationLogService.log("新增出库", "outbound_order", saved.getId(),
                "商品 " + saved.getGoodsName() + " × " + saved.getQuantity(), saved.getWarehouse());
        return ResponseEntity.ok(saved);
    }
}
