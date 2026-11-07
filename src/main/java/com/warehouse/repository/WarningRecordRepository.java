package com.warehouse.repository;

import com.warehouse.entity.WarningRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface WarningRecordRepository extends JpaRepository<WarningRecord, Long> {
    List<WarningRecord> findAllByOrderByCreateTimeDesc();

    List<WarningRecord> findAllByWarehouseOrderByCreateTimeDesc(String warehouse);

    void deleteByStatus(String status);

    void deleteByStatusAndWarehouse(String status, String warehouse);

    /** 重算时替换同一商品同一类型的旧记录，避免预警明细堆积重复行 */
    void deleteByGoodsIdAndWarningType(Long goodsId, String warningType);

    long countByStatus(String status);

    long countByWarehouse(String warehouse);

    long countByStatusAndWarehouse(String status, String warehouse);
}