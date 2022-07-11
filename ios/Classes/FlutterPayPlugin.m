#import "FlutterPayPlugin.h"
#if __has_include(<flutter_pay/flutter_pay-Swift.h>)
#import <flutter_pay/flutter_pay-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_pay-Swift.h"
#endif

#import "PaySdkManager.h"
#import "WeChatPayTool.h"
#import "WXApi.h"

FlutterMethodChannel *_methodChannel;

@implementation FlutterPayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//  [SwiftFlutterPayPlugin registerWithRegistrar:registrar];
	FlutterMethodChannel* channel = [FlutterMethodChannel
	                                 methodChannelWithName:@"flutter_pay"
	                                 binaryMessenger:[registrar messenger]];
	_methodChannel = channel;
	FlutterPayPlugin* instance = [[FlutterPayPlugin alloc] init];
	[registrar addMethodCallDelegate:instance channel:channel];
	[registrar addApplicationDelegate:instance];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSLog(@"flutter_pay::call.method %@", call.method);
    NSLog(@"flutter_pay::call.arguments %@", call.arguments);

    if([@"init" isEqualToString:call.method]) {
        //初始化
#ifdef IapPay
        BOOL canPay = [[PaySdkManager sharedInstance] isCanPay];
        result(@(canPay));
#else
        NSDictionary *params = (NSDictionary *)call.arguments;
        BOOL res =[[PaySdkManager sharedInstance] initSDK:params];
        result(@(res));
#endif
    } else if ([@"iapSetup" isEqualToString:call.method]) {
        //配置iap
        NSDictionary *params = (NSDictionary *)call.arguments;
        NSNumber *isSandbox = params[@"iapSandBox"];
        [[PaySdkManager sharedInstance] setupIap:isSandbox.boolValue];
        result(@YES);
    } else if([@"IapPayAction" isEqualToString:call.method]) {
        //调起iap支付
        NSDictionary *params = (NSDictionary *)call.arguments;
        NSString *productId = (params[@"goodsCode"] != nil) ? params[@"goodsCode"] : @"testDiamond1";
//        NSString *objectId = (params[@"objectId"] != nil) ? params[@"objectId"] : @"orderTestDiamond1";
        [[PaySdkManager sharedInstance] payAction:productId finish:^(NSString * _Nonnull goodsCode, NSString * _Nonnull transactionId, NSString * _Nonnull errorMsg, BOOL success, NSDictionary * _Nullable params) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"goodsCode"] = goodsCode;
            dict[@"transactionId"] = transactionId;
            dict[@"errorMsg"] = errorMsg;
            dict[@"success"] = @(success);
            dict[@"params"] = params;
            result(dict);
        }];
    } else if ([@"finalIapPay" isEqualToString:call.method]) {
        //验证成功调用结束iap
        NSDictionary *params = (NSDictionary *)call.arguments;
        NSString *goodsCode = (params[@"goodsCode"] != nil) ? params[@"goodsCode"] : @"testDiamond1";
        [[PaySdkManager sharedInstance] finishPayAction:goodsCode];
        result(@YES);
    } else if ([@"checkOutUnFinish" isEqualToString:call.method]) {
        //检测检验未完成
        [self _checkoutUnfinish];
        result(@YES);
    } else if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"payWithWechat" isEqualToString:call.method]){
        //调起微信支付
        [[PaySdkManager sharedInstance] wechatPayAction:call.arguments invokeCompletion:^(BOOL success) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            SUCCESS(200, "ok"),
//            DEFAULT_ERROR(300, "客户端内部错误"),
//            SDK_NOT_INIT(301, "SDK未初始化"),
            if (success == true) {
                dict[@"code"] = @200;
                dict[@"msg"] = @"ok";
            } else {
                dict[@"code"] = @300;
                dict[@"msg"] = @"客户端内部错误";
            }
            result(dict);
        } payResult:^(int code, NSString * _Nonnull msg, NSString * _Nonnull returnKey) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"msg"] = msg;
            dict[@"returnKey"] = returnKey;
            dict[@"code"] = @(code);
            [_methodChannel invokeMethod:@"wxPayResult" arguments:dict];
        }];
    } else if ([@"payWithAlipay" isEqualToString:call.method]) {
        //调起支付宝支付
        [[PaySdkManager sharedInstance] aliPayAction:call.arguments payResult:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic);
        }];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSLog(@"Pay SDK Plugin::application:didFinishLaunchingWithOptions");
#ifdef IapPay
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self _checkoutUnfinish];
	});
#endif
	return true;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:WeChatPayTool.sharedInstance];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[PaySdkManager sharedInstance] aliPayprocessOrder:url];
        return YES;
    }
    return [WXApi handleOpenURL:url delegate:WeChatPayTool.sharedInstance];
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options: (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if ([url.host isEqualToString:@"safepay"]) {
     //跳转支付宝钱包进行支付，处理支付结果
     [[PaySdkManager sharedInstance] aliPayprocessOrder:url];
     return YES;
    }
    return [WXApi handleOpenURL:url delegate:WeChatPayTool.sharedInstance];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *_Nonnull))restorationHandler {
    return [WXApi handleOpenUniversalLink:userActivity delegate:WeChatPayTool.sharedInstance];
}

- (void)_checkoutUnfinish {
#ifdef IapPay
	__weak __typeof(self) weakSelf = self;
	[[PaySdkManager sharedInstance] applicationIapWithFinished:^(NSString * _Nonnull goodsCode, NSString * _Nonnull transactionId, NSString * _Nonnull errorMsg, BOOL success, NSDictionary * _Nullable params) {
	         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	         dict[@"goodsCode"] = goodsCode;
	         dict[@"transactionId"] = transactionId;
	         dict[@"errorMsg"] = errorMsg;
	         dict[@"success"] = @(success);
	         dict[@"params"] = params;
	         [weakSelf invokeMethodCheckOutIap:dict];
	 }];
#endif
}

- (void)invokeMethodCheckOutIap:(NSDictionary *)sender {
    //检测结果通知
    [_methodChannel invokeMethod:@"IapCheckOut" arguments:sender];
}

@end
