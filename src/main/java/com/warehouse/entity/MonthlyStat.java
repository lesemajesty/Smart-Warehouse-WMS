package com.warehouse.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "monthly_stat")
public class MonthlyStat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // year_month 是 MySQL 8 保留字，列名改用 stat_month
    @Column(name = "stat_month", nullable = false, unique = true, length = 7)
    private String yearMonth;     // yyyy-MM
    private Integer inboundTotal;  // 本月入库总量
    private Integer outboundTotal; // 本月出库总量

    public MonthlyStat() {}

    public MonthlyStat(Long id, String yearMonth, Integer inboundTotal, Integer outboundTotal) {
        this.id = id;
        this.yearMonth = yearMonth;
        this.inboundTotal = inboundTotal;
        this.outboundTotal = outboundTotal;
    }

    // getter/setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getYearMonth() { return yearMonth; }
    public void setYearMonth(String yearMonth) { this.yearMonth = yearMonth; }

    public Integer getInboundTotal() { return inboundTotal; }
    public void setInboundTotal(Integer inboundTotal) { this.inboundTotal = inboundTotal; }

    public Integer getOutboundTotal() { return outboundTotal; }
    public void setOutboundTotal(Integer outboundTotal) { this.outboundTotal = outboundTotal; }
}