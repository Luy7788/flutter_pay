//
//  InAppPurResult.h
//  pay_sdk_plugin
//
//  Created by Luy on 2020/10/29.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InAppPurResult : NSObject

/**
 ture表示成功
 */
@property (copy, nonatomic) NSString * _Nullable result;
@property (copy, nonatomic) NSString *_Nullable msg;
@property (strong, nonatomic) id _Nullable data;
@property (copy, nonatomic) NSString *_Nullable transaction_id;
@property (strong, nonatomic) NSMutableArray * transationArray;

- (BOOL)isSucc;


/**
 获得一个reslut对象
 
 @param result result
 @param data data
 @param msg msg
 @param transactionId 交易id
 @return result对象
 */
+ (instancetype _Nonnull)resultWithResult:(nullable NSString *)result
                                     data:(nullable id)data
                                      msg:(nullable NSString *)msg
                            transactionId:(nullable NSString *)transactionId;


@end

typedef void(^InAppPurCompletionHandler)(InAppPurResult * _Nonnull result);

NS_ASSUME_NONNULL_END
