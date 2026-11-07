package com.warehouse.repository;

import com.warehouse.entity.InboundOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InboundOrderRepository extends JpaRepository<InboundOrder, Long> {
    List<InboundOrder> findAllByOrderByInboundTimeDesc();

    List<InboundOrder> findAllByWarehouseOrderByInboundTimeDesc(String warehouse);
}
