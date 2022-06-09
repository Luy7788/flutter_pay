package com.hx.flutter_pay.net;

/**
 * Created by imndx on 2017/12/15.
 */

public interface Callback<T> {
    void onSuccess(T t);

    void onFailure(int code, String message);
}
