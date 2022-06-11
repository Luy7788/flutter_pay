package com.hx.flutter_pay.pay;

import android.os.Handler;
import android.os.Looper;

import com.tencent.mm.opensdk.modelbase.BaseResp;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class FlutterChannelHelper implements EventChannel.StreamHandler {

    private MethodChannel methodChannel;

    private EventChannel eventChannel;

    private Handler handler = new Handler(Looper.getMainLooper());

    private EventChannel.EventSink event;

    private static MethodChannel.Result _callback;

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.event = events;
    }

    @Override
    public void onCancel(Object arguments) {

    }

    private static final class ManagerHolder {
        private static FlutterChannelHelper INSTANCE;

        static {
            INSTANCE = new FlutterChannelHelper();
        }
    }

    private FlutterChannelHelper() {
    }

    public static FlutterChannelHelper getInstance() {
        return FlutterChannelHelper.ManagerHolder.INSTANCE;
    }

    private void setMethodChannel(MethodChannel channel) {
        this.methodChannel = channel;
    }

    public static void init(MethodChannel methodChannel, EventChannel eventChannel, final MethodChannel.Result callback) {
        ManagerHolder.INSTANCE.setMethodChannel(methodChannel);
//        ManagerHolder.INSTANCE.setEventChannel(eventChannel);
        _callback = callback;
    }

    private void setEventChannel(EventChannel eventChannel) {
        eventChannel.setStreamHandler(this);
        this.eventChannel = eventChannel;
    }

    private void assertMethodChannel() {
        if (this.methodChannel == null) {
        }
    }


    public void eventSendSuccess(final Map<String, Object> result) {
        if (event == null) {
            Log.e("eventChannel", "event channel is null");
            return;
        }
        handler.post(new Runnable() {
            @Override
            public void run() {
                event.success(result);
            }
        });

    }

    private void channelPostResult(final String method, final Object value) {

       if (methodChannel == null) {
           return;
       };
        handler.post(new Runnable() {
            @Override
            public void run() {
                methodChannel.invokeMethod(method, value);
            }
        });
    }


    public void postWxPayResult(BaseResp resp) {
        final Map<String, Object> result = new HashMap<>();
        result.put("code", resp.errCode);
        result.put("msg", resp.errStr);
        System.out.println("==========================");
        System.out.println(result.toString());
//        channelPostResult("wxPayResult", result);
        _callback.success(result);
    }


}
