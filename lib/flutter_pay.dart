import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'model/ali_pay_result.dart';
import 'model/wx_pay_request.dart';
import 'model/iap_result.dart';
import 'model/channel_result.dart';

class FlutterPay {
  static const MethodChannel _channel = MethodChannel('flutter_pay');

  static Function(IapResult result)? _iapLaunchCallback;
  static Function(bool success)? _wechatPayCallback;
  static String _appScheme = "";

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 初始化方法
  /// wechatAppId 微信id
  /// aliPayAppId 支付宝id
  /// appScheme iOS配置的urlScheme
  /// universalLink iOS配置的universalLink
  /// isIapSandBox 是否IAP沙箱环境
  /// iapLaunchCheckout IAP支付APP启动检查回调
  /// wechatPayResult 微信支付结果回调
  /// 支付宝支付结果直接通过发起支付时返回
  static void initConfig({
    String? wechatAppId,
    String? aliPayAppId,
    String? appScheme,
    String? universalLink,
    bool isIapSandBox = false,
    void Function(IapResult result)? iapLaunchCheckout,
    void Function(bool success)? wechatPayResult,
  }) {
    methodListener();
    _iapLaunchCallback = iapLaunchCheckout;
    _wechatPayCallback = wechatPayResult;
    var argument = {
      "appScheme": appScheme ?? "",
      "wechatAppId": wechatAppId ?? "",
      "aliPayAppId": aliPayAppId ?? "",
      "universalLink": universalLink ?? "",
    };
    _appScheme = appScheme ?? "";
    _channel.invokeMethod('init', argument).then((value) {
      if (Platform.isIOS == true) {
        Map _temp = {};
        _temp["iapSandBox"] = isIapSandBox;
        _channel.invokeMethod('iapSetup', _temp);
      }
    });
  }

  ///调起微信支付
  ///WxPayRequest 请求参数，具体看注释[WxPayRequest]
  ///ChannelResult 返回调起结果,非支付结果
  static Future<ChannelResult> payWithWechat(WxPayRequest request) async {
    dynamic _temp = await _channel.invokeMethod("payWithWechat", request.toJson());
    Map<String, dynamic> _result = Map<String, dynamic>.from(_temp);
    ChannelResult result = ChannelResult.fromJson(_result);
    return result;
  }

  /// 调起支付宝支付
  /// payInfo 拼装的发起支付信息，字符串类型
  /// isSandbox 是否沙盒环境
  /// AliPayResult 返回支付结果
  static Future<AliPayResult> payWithAliPay(String payInfo, {bool? isSandbox}) async {
    var _data = {
      "payInfo": payInfo,
      "appScheme": _appScheme,
      "isSandbox": isSandbox ?? false
    };
    dynamic _temp = await _channel.invokeMethod("payWithAlipay", _data);
    Map<String, dynamic> _result = Map<String, dynamic>.from(_temp);
    AliPayResult result = AliPayResult.fromJson(_result);
    return result;
  }

  /// 调起iap支付
  /// goodsCode 商品码|商品ID
  /// 返回支付结果，仍需与接口进一步核对订单
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

  /// 验证成功调用结束iap
  static Future finishIapPay({String? goodsCode}) async {
    if (Platform.isIOS == false) return;
    Map _temp = {};
    _temp["goodsCode"] = goodsCode;
    var _result = await _channel.invokeMethod('finalIapPay', _temp);
    // Map<String, dynamic> result = Map<String, dynamic>.from(_result);
    debugPrint('finalIapPay result: $_result');
  }

  /// 手动检测
  static checkOutUnFinishIap() async {
    if (Platform.isIOS == false) return;
    var result = await _channel.invokeMethod('checkOutUnFinish');
    debugPrint('checkOutUnFinishIap $result');
  }

  /// 防止丢单
  static void _launchCheckOutIap(IapResult model) async {
    if (Platform.isIOS == false) return;
    if (_iapLaunchCallback != null) {
      _iapLaunchCallback!(model);
    } else {
      await Future.delayed(const Duration(seconds: 5));
      _launchCheckOutIap(model);
    }
  }

  /// 监听方法
  static void methodListener() {
    //接收原生传递来的MethodChannel参数
    _channel.setMethodCallHandler((call) async {
      debugPrint("flutter_pay 接收到原生调用 -> method :${call.method}");
      debugPrint("flutter_pay 接收到原生调用 -> arguments :${call.arguments}");
      switch (call.method) {
        //IAP检查通知
        case "IapCheckOut":
          Map<String, dynamic> result = Map<String, dynamic>.from(call.arguments);
          IapResult model = IapResult.fromJson(result);
          _launchCheckOutIap(model);
          break;

        //微信支付结果回调
        case "wxPayResult":
          //返回code、msg、returnKey
          Map<String, dynamic> result = Map<String, dynamic>.from(call.arguments);
          int code = result['code'] ?? -2; //0成功|-2用户取消|-1错误
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
