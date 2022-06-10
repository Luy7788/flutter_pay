package com.hx.flutter_pay.pay.model;

import com.hx.flutter_pay.pay.consts.SendErrorEnum;
import com.hx.flutter_pay.pay.util.BeanUtils;

import java.util.HashMap;
import java.util.Map;

public class FlutterResult {

    private Integer code;

    private String msg;

    private Object data;

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

    public static Map<String, Object> ok(Object object) {
        FlutterResult result = new FlutterResult();
        result.setCode(SendErrorEnum.SUCCESS.getCode());
        result.setMsg(SendErrorEnum.SUCCESS.getMsg());
        result.setData(object);
        try {
            return BeanUtils.objectToMap(result);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            return fail();
        }
    }
    public static Map<String, Object> ok() {
        FlutterResult result = new FlutterResult();
        result.setCode(SendErrorEnum.SUCCESS.getCode());
        result.setMsg(SendErrorEnum.SUCCESS.getMsg());
        try {
            return BeanUtils.objectToMap(result);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            return fail();
        }
    }

    public static Map<String, Object> fail(Integer code, String msg) {
        FlutterResult result = new FlutterResult();
        result.setCode(code);
        result.setMsg(msg);
        try {
            return BeanUtils.objectToMap(result);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            return fail();
        }
    }

    public static Map<String, Object> fail() {
        Map<String, Object> fail = new HashMap<>();
        fail.put("code", SendErrorEnum.DEFAULT_ERROR.getCode());
        fail.put("msg", SendErrorEnum.DEFAULT_ERROR.getMsg());
        return fail;
    }
}
