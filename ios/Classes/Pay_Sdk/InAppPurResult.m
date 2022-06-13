//
//  InAppPurResult.m
//  pay_sdk_plugin
//
//  Created by Luy on 2020/10/29.
//

#import "InAppPurResult.h"

@implementation InAppPurResult

- (BOOL)isSucc {
    return self.result.boolValue;
}

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
                            transactionId:(nullable NSString *)transactionId {
    
    InAppPurResult *res = [InAppPurResult new];
    res.result = result;
    res.msg = msg;
    res.data = data;
    res.transaction_id = transactionId;
    
    return res;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{result:%@, msg:%@, data:%@}", self.result ?: @"nil.", self.msg ?: @"nil.", self.data ?: @"nil."];
}


@end
