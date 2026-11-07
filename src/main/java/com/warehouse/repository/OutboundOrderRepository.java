package com.warehouse.repository;

import com.warehouse.entity.OutboundOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OutboundOrderRepository extends JpaRepository<OutboundOrder, Long> {
    List<OutboundOrder> findAllByOrderByOutboundTimeDesc();

    List<OutboundOrder> findAllByWarehouseOrderByOutboundTimeDesc(String warehouse);
}
