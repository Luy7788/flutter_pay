package com.hx.flutter_pay.pay;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.hx.flutter_pay.pay.FlutterChannelHelper;
import com.hx.flutter_pay.pay.PayManager;

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
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private MethodChannel channel;

    public static String CHANNEL_EVENT = "flutter_pay_event";

    private Context context;

    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_pay");
        channel.setMethodCallHandler(this);
        this.context = flutterPluginBinding.getApplicationContext();
        FlutterChannelHelper.init(channel, null, new MethodChannel.Result() {
            @Override
            public void success(Object result) {
                channel.invokeMethod("wxPayResult", result);
            }

            @Override
            public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {

            }

            @Override
            public void notImplemented() {

            }
        });
        PayManager.init(context);
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_pay");
        channel.setMethodCallHandler(new com.hx.flutter_pay.pay.FlutterPayPlugin());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "payWithWechat":
                PayManager.getInstance().payWithWechat(call, result);
                break;
            case "payWithAlipay":
                String payInfo = (String) call.arguments;
                PayManager.getInstance().payWithAlipay(payInfo, true, result);
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
//        checkPerssion();
//        binding.addRequestPermissionsResultListener(new PluginRegistry.RequestPermissionsResultListener() {
//            @Override
//            public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
//                switch (requestCode) {
//                    case mPermissionCode:
//                        if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_DENIED) {
//                            Toast.makeText(binding.getActivity(),"已拒绝访问设备上照片及文件权限!",Toast.LENGTH_SHORT).show();
//                        } else {
//                            initXXXXXX();
//                        }
//                        break;
//                }
//                return false;
//            }
//        });
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.i("FlutterPayPlugin", "onDetachedFromActivityForConfigChanges");

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        Log.e("FlutterPayPlugin", "onReattachedToActivityForConfigChanges");
    }

    @Override
    public void onDetachedFromActivity() {
        Log.e("FlutterPayPlugin", "onDetachedFromActivity");
    }
}
