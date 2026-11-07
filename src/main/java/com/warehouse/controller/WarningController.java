package com.warehouse.controller;

import com.warehouse.entity.WarningRecord;
import com.warehouse.service.OperationLogService;
import com.warehouse.service.WarehouseScopeService;
import com.warehouse.service.WarningService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/warnings")
public class WarningController {
    private final WarningService warningService;
    private final WarehouseScopeService warehouseScopeService;
    private final OperationLogService operationLogService;

    public WarningController(WarningService warningService, WarehouseScopeService warehouseScopeService,
                             OperationLogService operationLogService) {
        this.warningService = warningService;
        this.warehouseScopeService = warehouseScopeService;
        this.operationLogService = operationLogService;
    }

    @GetMapping
    public ResponseEntity<List<WarningRecord>> getAllWarnings(Authentication authentication) {
        return ResponseEntity.ok(warningService.getWarnings(warehouseScopeService.scope(authentication)));
    }

    @PostMapping("/check")
    @PreAuthorize("hasAnyRole('ADMIN', 'WAREHOUSE')")
    public ResponseEntity<Void> manualCheck(Authentication authentication) {
        warningService.manualCheckWarnings(warehouseScopeService.requireOperable(authentication));
        operationLogService.log("检查预警", "warning", null, "手动重算预警");
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/process")
    @PreAuthorize("hasAnyRole('ADMIN', 'WAREHOUSE')")
    public ResponseEntity<Void> processWarning(@PathVariable Long id, Authentication authentication) {
        warningService.processWarning(id, warehouseScopeService.requireOperable(authentication));
        operationLogService.log("处理预警", "warning", id, "处理预警记录 " + id);
        return ResponseEntity.ok().build();
    }
}