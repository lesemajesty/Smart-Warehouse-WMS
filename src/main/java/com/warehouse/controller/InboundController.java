package com.warehouse.controller;

import com.warehouse.entity.InboundOrder;
import com.warehouse.repository.InboundOrderRepository;
import com.warehouse.service.OperationLogService;
import com.warehouse.service.StockService;
import com.warehouse.service.WarehouseScopeService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inbound")
public class InboundController {

    private final InboundOrderRepository inboundRepository;
    private final StockService stockService;
    private final WarehouseScopeService warehouseScopeService;
    private final OperationLogService operationLogService;

    public InboundController(InboundOrderRepository inboundRepository, StockService stockService,
                             WarehouseScopeService warehouseScopeService,
                             OperationLogService operationLogService) {
        this.inboundRepository = inboundRepository;
        this.stockService = stockService;
        this.warehouseScopeService = warehouseScopeService;
        this.operationLogService = operationLogService;
    }

    @GetMapping
    public List<InboundOrder> list(Authentication authentication) {
        String scope = warehouseScopeService.scope(authentication);
        if (scope == null) {
            return inboundRepository.findAllByOrderByInboundTimeDesc();
        }
        return inboundRepository.findAllByWarehouseOrderByInboundTimeDesc(scope);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'WAREHOUSE')")
    public ResponseEntity<InboundOrder> create(@RequestBody InboundOrder order, Authentication authentication) {
        String scope = warehouseScopeService.requireOperable(authentication);
        InboundOrder saved = stockService.receive(
                order.getGoodsId(), order.getQuantity(), authentication.getName(), order.getOrderNo(), scope);
        operationLogService.log("新增入库", "inbound_order", saved.getId(),
                "商品 " + saved.getGoodsName() + " × " + saved.getQuantity(), saved.getWarehouse());
        return ResponseEntity.ok(saved);
    }
}
