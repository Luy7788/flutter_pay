//package com.hx.flutter_pay.pay.wechat;
//
//import android.app.Activity;
//import android.content.Intent;
//import android.os.Bundle;
//import android.util.Log;
//
//import com.hx.flutter_pay.pay.FlutterChannelHelper;
//import com.hx.flutter_pay.pay.PayManager;
//import com.tencent.mm.opensdk.constants.ConstantsAPI;
//import com.tencent.mm.opensdk.modelbase.BaseReq;
//import com.tencent.mm.opensdk.modelbase.BaseResp;
//import com.tencent.mm.opensdk.openapi.IWXAPI;
//import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
//
//
//public class WXEntryActivity extends Activity implements IWXAPIEventHandler {
//
//    private static String TAG = "FlutterPayPlugin.WXEntryActivity";
//
//    private IWXAPI api;
//
//    @Override
//    public void onCreate(Bundle savedInstanceState) {
//        Log.i(TAG, "onCreate!");
//        super.onCreate(savedInstanceState);
////        api = WXAPIFactory.createWXAPI(this, PayManager.getInstance().getWxAppId(), false);
//        api = PayManager.getInstance().getApi();
//        Intent intent = getIntent();
//        api.handleIntent(intent, this);
//    }
//
//    @Override
//    protected void onNewIntent(Intent intent) {
//        Log.i(TAG, "onNewIntent!");
//        super.onNewIntent(intent);
//        api = PayManager.getInstance().getApi();
//        setIntent(intent);
//        api.handleIntent(intent, this);
//    }
//
//    @Override
//    public void onReq(BaseReq req) {
//        Log.i(TAG, "on onReq!");
//        if (PayManager.getInstance().wechatHandle != null) {
//            PayManager.getInstance().wechatHandle.onReq(req, this);
//        }
//    }
//
//    @Override
//    public void onResp(BaseResp resp) {
//        Log.i(TAG, "onResp, errCode = " + resp.errCode);
//        if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
////            Toast.makeText(this, "" + ", type=" + resp.getType(), Toast.LENGTH_SHORT).show();
//            FlutterChannelHelper.getInstance().postWxPayResult(resp);
//            finish();
//        } else {
//            if (PayManager.getInstance().wechatHandle != null) {
//                PayManager.getInstance().wechatHandle.onResp(resp, this);
//            }
//        }
//    }
//}