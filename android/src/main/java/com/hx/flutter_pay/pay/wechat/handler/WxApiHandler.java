package com.hx.flutter_pay.pay.wechat.handler;

import android.content.Context;

import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;

public interface WxApiHandler {
    void onReq(BaseReq baseReq, Context context);
    void onResp(BaseResp baseResp, Context context);
}
