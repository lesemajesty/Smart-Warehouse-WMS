package com.warehouse.repository;

import com.warehouse.entity.InboundRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InboundRecordRepository extends JpaRepository<InboundRecord, Long> {
}
