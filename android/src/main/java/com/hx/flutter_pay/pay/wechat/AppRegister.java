package com.hx.flutter_pay.pay.wechat;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.hx.flutter_pay.pay.PayManager;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

public class AppRegister extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        final IWXAPI api = WXAPIFactory.createWXAPI(context, null, false);
        String appId = PayManager.getInstance().getWxAppId();//this.getMetaDataFromApp(context);
        // 将该app注册到微信
        api.registerApp(appId);
    }

    //获取value
//    private String getMetaDataFromApp(Context context) {
//        String value = "";
//        try {
//            ApplicationInfo appInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(),
//                    PackageManager.GET_META_DATA);
//            value = appInfo.metaData.getString("com.wechatl.app_id"); //com.wechat.appId
//        } catch (PackageManager.NameNotFoundException e) {
//            e.printStackTrace();
//        }
//        return value;
//    }
}