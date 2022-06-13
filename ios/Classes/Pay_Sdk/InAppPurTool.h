//
//  InAppPurTool.h
//  pay_sdk_plugin
//
//  Created by Luy on 2020/10/29.
//

#define IapPay 1

static NSString *const InAppPurUploadReceiptToServerDidSuccessKey = @"InAppPurUploadReceiptToServerDidSuccess";

#import <Foundation/Foundation.h>
#import "InAppPurResult.h"

#ifdef IapPay
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InAppPurTool : NSObject
@property(nonatomic, assign) BOOL isSandBox;

+ (instancetype)sharedInAppPurTool;

/**
 发起支付

 @param productId 内购商品ID
 @param applicationUsername 用户信息
 @param finishedBlock 回调
 */
+ (void)hy_iapWithProductId:(NSString *)productId
        applicationUsername:(NSString *)applicationUsername
              finishedBlock:(InAppPurCompletionHandler)finishedBlock;

/**
 app刚进入前台时使用这个处理监听事件

 @param finishedBlock 内购完成时的回调，之后可以上传交易凭证了
 */
+ (void)hy_applicationIapWithFinishedBlock:(InAppPurCompletionHandler)finishedBlock;

+ (SKPaymentTransaction *)getCurrentTransaction;


@end

NS_ASSUME_NONNULL_END

#endif
