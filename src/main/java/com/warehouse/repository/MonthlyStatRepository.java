package com.warehouse.repository;

import com.warehouse.entity.MonthlyStat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface MonthlyStatRepository extends JpaRepository<MonthlyStat, Long> {
    Optional<MonthlyStat> findByYearMonth(String yearMonth);

    List<MonthlyStat> findAllByOrderByYearMonthAsc();
}