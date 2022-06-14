//
//  WeChatPayTool.m
//  flutter_pay
//
//  Created by Luy on 2022/6/14.
//

#import "WeChatPayTool.h"
#import "WXApi.h"

@implementation WeChatPayTool

+ (instancetype)sharedInstance {
    static WeChatPayTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[super allocWithZone:NULL] init];
    });
    return tool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [WeChatPayTool sharedInstance];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [WeChatPayTool sharedInstance];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [WeChatPayTool sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (BOOL)registerWithAppID:(NSString *)appId universalLink:(NSString *)universalLink {
    if (DEBUG) {
        //在 register 之前打开 log , 后续可以根据 log 排查问题
        [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
            NSLog(@"WeChatSDK: %@", log);
        }];
        //务必在调用自检函数前注册
        bool result = [WXApi registerApp:appId universalLink:universalLink];
        //调用自检函数
        [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
            //        WXULCheckStep值说明:
            //        step = WXULCheckStepParams: 参数检查
            //        step = WXULCheckStepSystemVersion: 当前系统版本检查
            //        step = WXULCheckStepWechatVersion: 微信客户端版本检查
            //        step = WXULCheckStepSDKInnerOperation: 微信 SDK 内部操作检查
            //        step = WXULCheckStepLaunchWechat: App拉起微信检查
            //        step = WXULCheckStepBackToCurrentApp: 由微信返回当前 App 检查
            //        step = WXULCheckStepFinal: 最终检查
            NSLog(@"%@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
        }];
        return result;
    } else {
        return [WXApi registerApp:appId universalLink:universalLink];
    }
}


- (void)payActionWithPartnerId:(NSString *)partnerId
                      prepayId:(NSString *)prepayId
                       package:(NSString *)package
                      nonceStr:(NSString *)nonceStr
                          sign:(NSString *)sign
                     timeStamp:(UInt32) timeStamp
                    completion:(void (^ __nullable)(BOOL success))completion {
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = partnerId;//@"10000100";
    request.prepayId= prepayId;//@"1101000000140415649af9fc314aa427";
    request.package = package;//@"Sign=WXPay";
    request.nonceStr= nonceStr;//@"a462b76e7436e98e0ed6e13c64b4fd1c";
    request.timeStamp = timeStamp;//1397527777;
    request.sign= sign;//@"582282D72DD2B03AD892830965F428CB16E7A256";
    [WXApi sendReq:request completion:completion];
}

@end
