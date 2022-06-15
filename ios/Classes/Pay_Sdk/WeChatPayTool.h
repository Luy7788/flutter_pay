//
//  WeChatPayTool.h
//  flutter_pay
//
//  Created by Luy on 2022/6/14.
//

#import <Foundation/Foundation.h>
@class BaseReq;
@class BaseResp;

NS_ASSUME_NONNULL_BEGIN

typedef void (^reqCallback)(BaseReq * req);
typedef void (^respCallback)(BaseResp * resp);

@interface WeChatPayTool : NSObject

+ (instancetype)sharedInstance;

- (void)setupOnReqCallback:(reqCallback)reqCallback onRespCallback:(respCallback)respCallback;

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
