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

#ifdef WeChatPay
	if([@"IapPayAction" isEqualToString:call.method]) {
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
	} else if ([@"iapSetup" isEqualToString:call.method]) {
		NSDictionary *params = (NSDictionary *)call.arguments;
		NSNumber *isSandbox = params[@"iapSandBox"];
		[[PaySdkManager sharedInstance] setupIap:isSandbox.boolValue];
		result(@YES);
	} else {
		result(FlutterMethodNotImplemented);
	}
#else
    
#endif
}

- (void)invokeMethodCheckOutIap:(NSDictionary *)sender {
	//检测结果通知
	[_methodChannel invokeMethod:@"IapCheckOut" arguments:sender];
}

#pragma mark - appdelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSLog(@"Pay SDK Plugin::application:didFinishLaunchingWithOptions");
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self _checkoutUnfinish];
	});
	return true;
}

- (void)_checkoutUnfinish {
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
}


@end
