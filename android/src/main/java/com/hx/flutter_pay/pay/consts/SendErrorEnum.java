package com.hx.flutter_pay.pay.consts;

public enum SendErrorEnum {
    //成功
    SUCCESS(200, "ok"),
    DEFAULT_ERROR(300, "客户端内部错误"),
    //未初始化SDK
    SDK_NOT_INIT(301, "SDK未初始化"),

    ;


    private int code;

    private String msg;

    SendErrorEnum(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public int getCode() {
        return this.code;
    }

    public String getMsg() {
        return this.msg;
    }

}
