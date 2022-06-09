import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'model/wx_pay_request.dart';
import 'model/iap_result.dart';
import 'model/channel_result.dart';

class FlutterPay {
  static const MethodChannel _channel = MethodChannel('flutter_pay');

  static Function(IapResult result)? _iapLaunchCallback;
  static Function(bool success)? _wechatPayCallback;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void initConfig({
    bool isIapSandBox = false,
    void Function(IapResult result)? iapLaunchCheckout,
    void Function(bool success)? wechatPayResult,
  }) {
    methodListener();
    _iapLaunchCallback = iapLaunchCheckout;
    _wechatPayCallback = wechatPayResult;
    if (Platform.isIOS == true) {
      Map _temp = {};
      _temp["iapSandBox"] = isIapSandBox;
      _channel.invokeMethod('iapSetup', _temp);
    }
  }

  static Future<ChannelResult> payWithWechat(WxPayRequest request) async {
    dynamic _temp =
        await _channel.invokeMethod("payWithWechat", request.toJson());
    Map<String, dynamic> _result = Map<String, dynamic>.from(_temp);
    ChannelResult result = ChannelResult.fromJson(_result);
    return result;
  }

  static Future<ChannelResult> payWithAliPay(String payStr) async {
    dynamic _temp = await _channel.invokeMethod("payWithAlipay", payStr);
    Map<String, dynamic> _result = Map<String, dynamic>.from(_temp);
    ChannelResult result = ChannelResult.fromJson(_result);
    return result;
  }

  //调起iap支付
  static Future<IapResult?> iapPay({String? goodsCode}) async {
    if (Platform.isIOS == false) return null;
    Map _temp = {};
    _temp["goodsCode"] = goodsCode;
    var _result = await _channel.invokeMethod('IapPayAction', _temp);
    Map<String, dynamic> result = Map<String, dynamic>.from(_result);
    debugPrint('pay result: $result');
    if (_result != null) {
      IapResult model = IapResult.fromJson(result);
      return model;
    }
    return null;
  }

  //验证成功调用结束iap
  static Future finishIapPay({String? goodsCode}) async {
    if (Platform.isIOS == false) return;
    Map _temp = {};
    _temp["goodsCode"] = goodsCode;
    var _result = await _channel.invokeMethod('finalIapPay', _temp);
    // Map<String, dynamic> result = Map<String, dynamic>.from(_result);
    debugPrint('finalIapPay result: $_result');
  }

  //手动检测
  static checkOutUnFinishIap() async {
    if (Platform.isIOS == false) return;
    var result = await _channel.invokeMethod('checkOutUnFinish');
    debugPrint('checkOutUnFinishIap $result');
  }

  //防止丢单
  static void _launchCheckOutIap(IapResult model) async {
    if (Platform.isIOS == false) return;
    if (_iapLaunchCallback != null) {
      _iapLaunchCallback!(model);
    } else {
      await Future.delayed(const Duration(seconds: 5));
      _launchCheckOutIap(model);
    }
  }

  //监听方法
  static void methodListener() {
    //接收原生传递来的MethodChannel参数
    _channel.setMethodCallHandler((call) async {
      debugPrint("flutter_pay 接收到原生调用 -> method :${call.method}");
      debugPrint("flutter_pay 接收到原生调用 -> arguments :${call.arguments}");
      switch (call.method) {
        case "IapCheckOut":
          Map<String, dynamic> result = Map<String, dynamic>.from(call.arguments);
          IapResult model = IapResult.fromJson(result);
          _launchCheckOutIap(model);
          break;

        case "wxPayResult":
          Map<String, dynamic> result = Map<String, dynamic>.from(call.arguments);
          int code = result['code'] ?? 0;
          if (_wechatPayCallback != null) {
            _wechatPayCallback!(code == 0);
          }
          break;

        default:
          // Map<String, dynamic> result = Map<String, dynamic>.from(call.arguments);
          break;
      }
      return;
    });
  }
}
