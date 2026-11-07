package com.warehouse.exception;

/** 跨仓库操作或未绑定仓库时抛出，统一返回 403。 */
public class WarehouseAccessException extends RuntimeException {
    public WarehouseAccessException(String message) {
        super(message);
    }
}
