package com.warehouse.repository;

import com.warehouse.entity.OutboundRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OutboundRecordRepository extends JpaRepository<OutboundRecord, Long> {
}
