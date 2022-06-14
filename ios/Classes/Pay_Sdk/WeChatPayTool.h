//
//  WeChatPayTool.h
//  flutter_pay
//
//  Created by Luy on 2022/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeChatPayTool : NSObject

+ (instancetype)sharedInstance;

//注册微信支付
- (BOOL)registerWithAppID:(NSString *)appId universalLink:(NSString *)universalLink;

//调起微信支付
- (void)payActionWithPartnerId:(NSString *)partnerId
                      prepayId:(NSString *)prepayId
                       package:(NSString *)package
                      nonceStr:(NSString *)nonceStr
                          sign:(NSString *)sign
                     timeStamp:(UInt32) timeStamp
                    completion:(void (^ __nullable)(BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
