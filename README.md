# flutter_pay

flutter支付插件，集成了iOS IAP内购、微信支付、支付宝支付，Android 微信支付、支付宝支付

## 目前分支说明
1. master 分支，包含当前所有的支付方式
2. IAP 分支，iOS只有内购，去掉微信和支付宝。安卓依旧有微信、支付宝
3. alipay_noutdid，处理支付宝SDK utdid冲突，如果报错utdid冲突使用这个分支，该分支保留所有支付

## 使用说明

#### 1. 工程配置

 Android: 
 ```

 ```

#### 2. 初始化方法

引入文件

```
import 'package:flutter_pay/flutter_pay.dart';
```

初始化方法

``` 
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
  })
```

 eg: 
 
```
FlutterPay.initConfig(
      appScheme: appScheme,
      wehatAppId: xxxx,
      aliPayAppId: xxxx
      universalLink: Config.universalLink,
      iapLaunchCheckout: (result) async {
        //IAP 启动检查
        if(result.success ==true && UserStorage.login == true) {
            //显示提示弹窗 "请稍候，正在检测内购"
            await checkOutResult(result);
            //隐藏弹窗
       } else if(result.errorMsg?.isNotEmpty == true) {
            Alert.show(context: AppGlobal.mainContext, title: result.errorMsg);
       }
      },
      wechatPayResult: (bool success) {
        //wechat支付结果
        debugPrint("微信支付结果: ${success == true ? "成功" : "失败"}");
        if (this._payResult != null) {
          this._payResult!(success);
        }
      },
    );
```

#### 3. 发起支付宝支付

```
  /// 调起支付宝支付
  /// payInfo 拼装的发起支付信息，字符串类型
  /// isSandbox 是否沙盒环境
  /// AliPayResult 返回支付结果
  static Future<AliPayResult> payWithAliPay(String payInfo, {bool? isSandbox}) 
```

#### 4. 发起微信支付

```
 ///调起微信支付
  ///WxPayRequest 请求参数，具体看注释[WxPayRequest]
  ///ChannelResult 返回调起结果,非支付结果
  static Future<ChannelResult> payWithWechat(WxPayRequest request)
  
  class WxPayRequest {
      String? appId;
      String? partnerId;
      String? prepayId;
      String? nonceStr;
      String? timeStamp;
      String? packageValue;
      String? sign;
      String? extData;
  }
```

#### 5. IAP内购

```
  /// 调起iap支付
  /// goodsCode 商品码|商品ID
  /// 返回支付结果，仍需与接口进一步核对订单
  static Future<IapResult?> iapPay({String? goodsCode})
```