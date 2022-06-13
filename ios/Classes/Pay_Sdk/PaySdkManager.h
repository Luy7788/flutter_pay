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

@interface PaySdkManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isCanPay;

- (void)setupIap:(bool)isSandBox;

- (void)applicationIapWithFinished:(PayFinifshBlock)checkOutBlock ;

- (void)payAction:(NSString *)goodsCode finish:(PayFinifshBlock)finishBlock;

- (void)finishPayAction:(NSString *)goodsCode;

@end

NS_ASSUME_NONNULL_END
