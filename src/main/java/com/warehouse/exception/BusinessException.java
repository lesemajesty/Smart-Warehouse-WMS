package com.warehouse.exception;

/**
 * 业务校验失败（库存不足、参数非法等），统一返回 400。
 */
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
