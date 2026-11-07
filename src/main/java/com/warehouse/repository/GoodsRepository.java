package com.warehouse.repository;

import com.warehouse.entity.Goods;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GoodsRepository extends JpaRepository<Goods, Long> {
    List<Goods> findAllByOrderByIdDesc();

    List<Goods> findAllByWarehouseOrderByIdDesc(String warehouse);

    /** 库存变动前锁行，避免并发下丢失更新 */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select g from Goods g where g.id = :id")
    Optional<Goods> findByIdForUpdate(@Param("id") Long id);
}
