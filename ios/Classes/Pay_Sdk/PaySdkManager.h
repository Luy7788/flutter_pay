//
//  PaySdkManager.h
//  pay_sdk_plugin
//
//  Created by Luy on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PayFinifshBlock)(NSString *goodsCode,
                               NSString *transactionId,
                               NSString *errorMsg,
                               BOOL success,
                               NSDictionary * _Nullable params);

typedef void(^WeChatPayBlock)(int code, NSString *msg, NSString *returnKey);
typedef void(^AliPayBlock)(NSDictionary *resultDic);

@interface PaySdkManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark - Wechat

- (BOOL)initSDK:(NSDictionary *)argument;

- (void)wechatPayAction:(NSDictionary *)argument
       invokeCompletion:(void (^ __nullable)(BOOL success))completion
              payResult:(WeChatPayBlock)payResult;

- (void)wechatPayResult:(int)code msg:(NSString *)message returnKey:(NSString *)returnKey;

#pragma mark - Alipay

- (void)aliPayAction:(NSDictionary *)argument payResult:(AliPayBlock)payResult;

- (void)aliPayprocessOrder:(NSURL *)url;

#pragma mark - IAP

- (BOOL)isCanPay;

- (void)setupIap:(bool)isSandBox;

- (void)applicationIapWithFinished:(PayFinifshBlock)checkOutBlock ;

- (void)payAction:(NSString *)goodsCode finish:(PayFinifshBlock)finishBlock;

- (void)finishPayAction:(NSString *)goodsCode;

@end

NS_ASSUME_NONNULL_END
