package com.hx.flutter_pay.pay.wechat;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.hx.flutter_pay.pay.FlutterChannelHelper;
import com.hx.flutter_pay.pay.PayManager;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler {

    private static String TAG = "MicroMsg.WXEntryActivity";

    private IWXAPI api;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        api = WXAPIFactory.createWXAPI(this, PayManager.getInstance().getWxAppId(), false);
        Intent intent = getIntent();
        api.handleIntent(intent, this);

    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        api.handleIntent(intent, this);
    }

    @Override
    public void onReq(BaseReq req) {
        Log.i(TAG, "on request!");
    }

    @Override
    public void onResp(BaseResp resp) {
        Log.i(TAG, "onPayFinish, errCode = " + resp.errCode);
        if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
//            Toast.makeText(this, "" + ", type=" + resp.getType(), Toast.LENGTH_SHORT).show();
            FlutterChannelHelper.getInstance().postWxPayResult(resp);
            finish();
        }
    }
}