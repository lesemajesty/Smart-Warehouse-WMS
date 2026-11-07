package com.warehouse.controller;

import com.warehouse.entity.MonthlyStat;
import com.warehouse.service.GoodsService;
import com.warehouse.service.StatisticsService;
import com.warehouse.service.WarehouseScopeService;
import com.warehouse.service.WarningService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {

    private final GoodsService goodsService;
    private final StatisticsService statisticsService;
    private final WarningService warningService;
    private final WarehouseScopeService warehouseScopeService;

    public StatisticsController(GoodsService goodsService,
                                StatisticsService statisticsService,
                                WarningService warningService,
                                WarehouseScopeService warehouseScopeService) {
        this.goodsService = goodsService;
        this.statisticsService = statisticsService;
        this.warningService = warningService;
        this.warehouseScopeService = warehouseScopeService;
    }

    /**
     * warningTotal：预警记录总数（含已处理）；
     * warningPending：未处理条数，和顶栏铃铛同口径。
     */
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboardData(Authentication authentication) {
        String scope = warehouseScopeService.scope(authentication);
        Map<String, Object> data = new HashMap<>();
        data.put("warningTotal", warningService.countAllWarnings(scope));
        data.put("warningPending", warningService.countPendingWarnings(scope));
        data.put("totalStock", goodsService.getTotalStock());
        data.put("lowStockSku", goodsService.getLowStockSkuCount());

        MonthlyStat stat = statisticsService.getCurrentMonthStat();
        data.put("monthlyInbound", stat.getInboundTotal());
        data.put("monthlyOutbound", stat.getOutboundTotal());
        data.put("trend", statisticsService.getTrend(6));

        return ResponseEntity.ok(data);
    }
}
