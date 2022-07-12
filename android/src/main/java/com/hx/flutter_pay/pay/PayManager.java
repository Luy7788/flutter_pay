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

import com.alipay.sdk.app.EnvUtils;
import com.alipay.sdk.app.PayTask;
import com.hx.flutter_pay.pay.alipay.PayResult;
import com.hx.flutter_pay.pay.model.FlutterResult;
import com.hx.flutter_pay.pay.util.MapUtil;
import com.hx.flutter_pay.pay.wechat.handler.WxApiHandler;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class PayManager {
    private Context context;

    private IWXAPI api;

    private String wxAppId;

    private String alipayAppId;

    private Handler handler = new Handler(Looper.getMainLooper());

    private Activity activity;

    public WxApiHandler wechatHandle;

    private static final String TAG = "FlutterPayPlugin.WxApiManager";

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
        this.wxAppId = wxAppId;
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
        this.alipayAppId = aliAppId;
    }

    public void initActivity(Activity activity) {
        this.activity = activity;
    }

    /*设置微信回调
    * 如果外部工程需要获取插件内的微信回调使用该方法*/
    public void setWechatHandle(WxApiHandler handle) {
        this.wechatHandle = handle;
    }

    /*设置微信api方法
    * 如果外部工程创建过IWXAPI，则传进来给插件用*/
    public void setWxAPI(IWXAPI api) {
        this.api = api;
    }

    /*设置微信请求onResp
    * 如果外部工程依赖微信onResp方法，则把onResp传进来*/
    public void wechatOnResp(BaseResp resp) {
        if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
            FlutterChannelHelper.getInstance().postWxPayResult(resp);
        }
    }

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
        PayReq request = new PayReq();
        String appid = MapUtil.getString(paramMap, "appId");
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
        Log.i(TAG, "pay with wechat result:" + done);
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

    /* 调起支付
    payInfo ：App 支付请求参数字符串，主要包含商家的订单信息，key=value 形式，以 & 连接。
    * */
    public void payWithAlipay(final String payInfo, boolean isSandbox, final MethodChannel.Result callback) {

        if (this.activity == null) {
            callback.success(FlutterResult.fail(-1, "sdk 未就绪！"));
            return;
        }
        //沙箱环境
        if (isSandbox) {
            EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX);
        }

        final Activity activity = this.activity;
        Runnable payRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    PayTask alipay = new PayTask(activity);
                    final Map<String, String> result = alipay.payV2(payInfo, true);
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.success(result);
                        }
                    });
                    PayResult payResult = new PayResult(result);
//                    /**
//                     * 对于支付结果，请商户依赖服务端的异步通知结果。同步通知结果，仅作为支付结束的通知。
//                     */
//                    String resultInfo = payResult.getResult();// 同步返回需要验证的信息
//                    String resultStatus = payResult.getResultStatus();
//                    // 判断resultStatus 为9000则代表支付成功
//                    if (TextUtils.equals(resultStatus, "9000")) {
//                        // 该笔订单是否真实支付成功，需要依赖服务端的异步通知。
//                        showAlert(PayDemoActivity.this, getString(R.string.pay_success) + payResult);
//                    } else {
//                        // 该笔订单真实的支付结果，需要依赖服务端的异步通知。
//                        showAlert(PayDemoActivity.this, getString(R.string.pay_failed) + payResult);
//                    }
                } catch (final Exception e) {
                    e.printStackTrace();
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.success(FlutterResult.fail(-1, e.getMessage()));
                        }
                    });
                }
            }
        };

        Thread payThread = new Thread(payRunnable);
        payThread.start();
    }

}
