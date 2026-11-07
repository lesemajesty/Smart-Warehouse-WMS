package com.warehouse.service;

import com.warehouse.entity.MonthlyStat;
import com.warehouse.repository.MonthlyStatRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class StatisticsService {
    private final MonthlyStatRepository monthlyStatRepository;

    public StatisticsService(MonthlyStatRepository monthlyStatRepository) {
        this.monthlyStatRepository = monthlyStatRepository;
    }

    private String getCurrentYearMonth() {
        return YearMonth.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
    }

    @Transactional
    public void addInbound(int quantity) {
        addToStat(getCurrentYearMonth(), quantity, true);
    }

    @Transactional
    public void addOutbound(int quantity) {
        addToStat(getCurrentYearMonth(), quantity, false);
    }

    private void addToStat(String yearMonth, int quantity, boolean isInbound) {
        MonthlyStat stat = monthlyStatRepository.findByYearMonth(yearMonth)
                .orElse(new MonthlyStat(null, yearMonth, 0, 0));
        if (isInbound) {
            stat.setInboundTotal(stat.getInboundTotal() + quantity);
        } else {
            stat.setOutboundTotal(stat.getOutboundTotal() + quantity);
        }
        monthlyStatRepository.save(stat);
    }

    public MonthlyStat getCurrentMonthStat() {
        String yearMonth = getCurrentYearMonth();
        return monthlyStatRepository.findByYearMonth(yearMonth)
                .orElse(new MonthlyStat(null, yearMonth, 0, 0));
    }

    /** 最近 N 个月趋势，缺数据的月份补 0 */
    public List<Map<String, Object>> getTrend(int months) {
        int count = Math.max(1, Math.min(months, 24));
        Map<String, MonthlyStat> byMonth = new HashMap<>();
        for (MonthlyStat stat : monthlyStatRepository.findAllByOrderByYearMonthAsc()) {
            byMonth.put(stat.getYearMonth(), stat);
        }

        DateTimeFormatter keyFormat = DateTimeFormatter.ofPattern("yyyy-MM");
        YearMonth current = YearMonth.now();
        List<Map<String, Object>> trend = new ArrayList<>();

        for (int i = count - 1; i >= 0; i--) {
            YearMonth month = current.minusMonths(i);
            String key = month.format(keyFormat);
            MonthlyStat stat = byMonth.get(key);
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("month", key);
            row.put("label", month.getMonthValue() + "月");
            row.put("inbound", stat == null ? 0 : stat.getInboundTotal());
            row.put("outbound", stat == null ? 0 : stat.getOutboundTotal());
            trend.add(row);
        }
        return trend;
    }
}