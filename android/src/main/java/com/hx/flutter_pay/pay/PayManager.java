package com.hx.flutter_pay.pay;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.hx.flutter_pay.pay.model.FlutterResult;
import com.hx.flutter_pay.pay.util.MapUtil;
import com.hx.flutter_pay.pay.wechat.handler.WxApiHandler;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

//import com.alipay.sdk.app.EnvUtils;
//import com.alipay.sdk.app.PayTask;

public class PayManager {
    private Context context;

    private IWXAPI api;

    private String wxAppId;

    private String alipayAppId;

    private Handler handler = new Handler(Looper.getMainLooper());

    private Activity activity;

    public WxApiHandler wechatHandle;

    private static final String TAG = "WxApiManager";

    private static final class ManagerHolder {
        static PayManager INSTANCE;

        static {
            INSTANCE = new PayManager();
        }

        private ManagerHolder() {

        }
    }

    public static PayManager getInstance() {
        return ManagerHolder.INSTANCE;
    }

    public static void init(Context context, String wxAppId, String aliAppId) {
        ManagerHolder.INSTANCE.initApi(context, wxAppId, aliAppId);
    }

    private void initApi(Context context, final String wxAppId, String aliAppId) {
        this.context = context;
        this.wxAppId = wxAppId;//this.getMetaData("com.wechat.appId");
//        this.api = WXAPIFactory.createWXAPI(context, wxAppId, true);
        this.api = WXAPIFactory.createWXAPI(context, wxAppId, false);
        // 将该app注册到微信
        this.api.registerApp(wxAppId);
        //建议动态监听微信启动广播进行注册到微信
        context.registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                // 将该app注册到微信
                api.registerApp(wxAppId);
            }
        }, new IntentFilter(ConstantsAPI.ACTION_REFRESH_WXAPP));
        this.alipayAppId = aliAppId;//this.getMetaData("com.alipay.appId");
    }

    public void initActivity(Activity activity) {
        this.activity = activity;
    }

    /*设置微信回调*/
    public void setWechatHandle(WxApiHandler handle) {
        this.wechatHandle = handle;
    }

//    private String getMetaData(String key) {
//        if (this.context == null) {
//            throw new NullPointerException("context is null");
//        }
//        String value = "";
//        try {
//            ApplicationInfo appInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(),
//                    PackageManager.GET_META_DATA);
//            Object fieldValue = appInfo.metaData.get(key);
//            if (fieldValue == null) {
//                throw new NullPointerException("appId is invalid");
//            }
//            value = fieldValue.toString();
//        } catch (PackageManager.NameNotFoundException e) {
//            e.printStackTrace();
//        }
//        return value;
//    }

    //获取value
    public String getWxAppId() {
        return this.wxAppId;
    }

    public IWXAPI getApi() {
        return this.api;
    }

    public void payWithWechat(@NonNull final MethodCall call, @NonNull final MethodChannel.Result result) {
        Log.i(TAG, "pay with wechat");
        if (this.api == null) {
            Log.e(TAG, "wechat api is null");
            result.success(FlutterResult.fail(-1, "wechat api is null"));
            return;
        }


        Map<String, Object> paramMap = (Map<String, Object>) call.arguments;
        Log.i(TAG, "pay with wechat");

        PayReq request = new PayReq();
        String appid = MapUtil.getString(paramMap, "appId");
        Log.i(TAG, "pay with wechat");
        if (TextUtils.isEmpty(appid)) {
            appid = wxAppId;
        }
        request.appId = appid;
        request.partnerId = MapUtil.getString(paramMap, "partnerId");
        request.packageValue = MapUtil.getString(paramMap, "packageValue");
        request.nonceStr = MapUtil.getString(paramMap, "nonceStr");
        request.prepayId = MapUtil.getString(paramMap, "prepayId");
        request.timeStamp = MapUtil.getString(paramMap, "timeStamp");
        request.sign = MapUtil.getString(paramMap, "sign");
        boolean done = api.sendReq(request);
        if (done) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    result.success(FlutterResult.ok());
                }
            });

        } else {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    result.success(FlutterResult.fail(-1, "调用微信支付失败"));
                }
            });

        }

    }

    //调起支付
    public void payWithAlipay(final String payInfo, boolean isSandbox, final MethodChannel.Result callback) {
//
//        if (this.activity == null) {
//            callback.success(FlutterResult.fail(-1, "sdk 未就绪！"));
//            return;
//        }
//        //沙箱环境
//        if (isSandbox) {
//            EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX);
//        }
//
//        final Activity activity = this.activity;
//        Runnable payRunnable = new Runnable() {
//            @Override
//            public void run() {
//                try {
//                    PayTask alipay = new PayTask(activity);
//                    final Map<String, String> result = alipay.payV2(payInfo, true);
//                    handler.post(new Runnable() {
//                        @Override
//                        public void run() {
//                            callback.success(result);
//                        }
//                    });
//
//                } catch (final Exception e) {
//                    e.printStackTrace();
//                    handler.post(new Runnable() {
//                        @Override
//                        public void run() {
//                            callback.success(FlutterResult.fail(-1, e.getMessage()));
//                        }
//                    });
//                }
//            }
//        };
//
//        Thread payThread = new Thread(payRunnable);
//        payThread.start();
    }

}
