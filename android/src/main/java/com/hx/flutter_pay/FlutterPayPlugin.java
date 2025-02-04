package com.hx.flutter_pay;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.hx.flutter_pay.pay.FlutterChannelHelper;
import com.hx.flutter_pay.pay.PayManager;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPayPlugin
 */
public class FlutterPayPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {

    private MethodChannel channel;

    private Context context;

    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_pay");
        channel.setMethodCallHandler(this);
        this.context = flutterPluginBinding.getApplicationContext();
        FlutterChannelHelper.init(channel, null, new MethodChannel.Result(){
            @Override
            public void success( Object result){
                channel.invokeMethod("wxPayResult",result);
            }

            @Override
            public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
            }

            @Override
            public void notImplemented() {
            }
        });
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_pay");
        channel.setMethodCallHandler(new FlutterPayPlugin());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        switch (call.method) {
            case "init": {
                Map<String, Object> paramMap = (Map<String, Object>) call.arguments;
                String wechatAppId = (String) paramMap.get("wechatAppId");
                String aliPayAppId = (String) paramMap.get("aliPayAppId");
                PayManager.init(this.context, wechatAppId, aliPayAppId);
            }
                break;
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "payWithWechat":
                PayManager.getInstance().payWithWechat(call, result);
                break;
            case "payWithAlipay":
                Map<String, Object> paramMap = (Map<String, Object>) call.arguments;
                String payInfo = (String) paramMap.get("payInfo");
                boolean isSandbox = (boolean) paramMap.get("isSandbox");
                PayManager.getInstance().payWithAlipay(payInfo, isSandbox, result);
                break;
            default:
                result.notImplemented();
        }
    }

    public Activity getActivity() {
        return this.activity;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.i("FlutterPayPlugin", "onAttachedToActivity");
        this.activity = binding.getActivity();
        PayManager.getInstance().initActivity(this.activity);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.i("FlutterPayPlugin", "onDetachedFromActivityForConfigChanges");

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        Log.i("FlutterPayPlugin", "onReattachedToActivityForConfigChanges");
    }

    @Override
    public void onDetachedFromActivity() {
        Log.i("FlutterPayPlugin", "onDetachedFromActivity");
    }
}
