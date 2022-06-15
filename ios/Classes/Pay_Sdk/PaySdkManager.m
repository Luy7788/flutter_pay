//
//  PaySdkManager.m
//  pay_sdk_plugin
//
//  Created by Luy on 2020/10/29.
//

#import "PaySdkManager.h"
#import "InAppPurTool.h"
#import "WeChatPayTool.h"

#define kAppPayUnFinishOrderKey @"UnFinishOrder"

#define NSLog(format,...) printf("%s\n",[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])


@interface PaySdkManager () {
    NSString *GoodsCode;
}
@property (nonatomic, assign) NSTimeInterval receiptTime;
//@property (nonatomic, copy) NSString *applicationUsername;
@property (nonatomic, copy) PayFinifshBlock finishBlock;
@property (nonatomic, copy) WeChatPayBlock wechatResult;

@end

@implementation PaySdkManager

+ (instancetype)sharedInstance {
    static PaySdkManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [PaySdkManager new];
    });
    return _instance;
}

#pragma mark - Wechat
- (BOOL)initSDK:(NSDictionary *)argument {
    //向微信注册
    NSString *wehatAppId = argument[@"wehatAppId"];
    NSString *universalLink = argument[@"universalLink"];
    return [[WeChatPayTool sharedInstance] registerWithAppID:wehatAppId universalLink:universalLink];
}

- (void)wechatPayAction:(NSDictionary *)argument
       invokeCompletion:(void (^ __nullable)(BOOL success))completion
              payResult:(WeChatPayBlock)payResult {
    NSString* partnerId = argument[@"partnerId"];
    NSString* prepayId = argument[@"prepayId"];
    NSString* packageValue = argument[@"packageValue"];
    NSString* nonceStr = argument[@"nonceStr"];
    NSString* timeStamp = argument[@"timeStamp"];
    NSString* sign = argument[@"sign"];
    self.wechatResult = payResult;
    [[WeChatPayTool sharedInstance] payActionWithPartnerId:partnerId
                                                  prepayId:prepayId
                                                   package:packageValue
                                                  nonceStr:nonceStr
                                                      sign:sign
                                                 timeStamp:timeStamp.intValue
                                                completion:completion];
}

- (void)wechatPayResult:(int)code msg:(NSString *)message returnKey:(NSString *)returnKey{
    if (self.wechatResult != nil) {
        self.wechatResult(code, message, returnKey);
    }
}

#pragma mark - IAP

- (void)saveUserGoodsCode:(NSString *)code {
    if (code == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kAppPayUnFinishOrderKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:code forKey:kAppPayUnFinishOrderKey];
    }
    NSLog(@"saveUserOrderId %@", [self getUnFinishGoodsCode]);
}

- (NSString *)getUnFinishGoodsCode {
    NSString *code = [[NSUserDefaults standardUserDefaults] valueForKey:kAppPayUnFinishOrderKey];
    return code;
}

- (BOOL)isCanPay {
#ifdef IapPay
    //是否允许内购
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"用户允许内购");
        return YES;
    }else{
        NSLog(@"用户不允许内购");
        return NO;
    }
#else
    return YES;
#endif
}

- (void)setupIap:(bool)isSandBox{
#ifdef IapPay
    [InAppPurTool sharedInAppPurTool].isSandBox = isSandBox;
#endif
}

- (void)payAction:(NSString *)goodsCode
           finish:(PayFinifshBlock)finishBlock {
#ifdef IapPay
    __weak __typeof(self)weakSelf = self;
    self.finishBlock = finishBlock;
    GoodsCode = goodsCode;
    NSLog(@"商品ID: %@", GoodsCode);
    [self saveUserGoodsCode:goodsCode];
    [InAppPurTool hy_iapWithProductId:goodsCode applicationUsername:goodsCode finishedBlock:^(InAppPurResult * _Nonnull result) {
        if (result.isSucc) {
            NSDictionary *params = [weakSelf _checkIsLoginAndUploadToServerWithReceipt:result.data goodsCode:goodsCode transactionId:result.transaction_id];
            weakSelf.finishBlock(goodsCode, result.transaction_id, result.msg, YES, params);
        } else {
            weakSelf.finishBlock(goodsCode, result.transaction_id, result.msg, NO, nil);
        }
    }];
#endif
}

//验证成功后调用
- (void)finishPayAction:(NSString *)goodsCode {
#ifdef IapPay
    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurUploadReceiptToServerDidSuccessKey object:nil];
    [self saveUserGoodsCode:nil];
    
#endif
}

- (void)applicationIapWithFinished:(PayFinifshBlock)checkOutBlock {
#ifdef IapPay
    __weak __typeof(self)weakSelf = self;
    [InAppPurTool hy_applicationIapWithFinishedBlock:^(InAppPurResult * _Nonnull result) {
        NSString *goodsCode = [InAppPurTool getCurrentTransaction].payment.applicationUsername;
        if(goodsCode.length == 0) {
            goodsCode = [weakSelf getUnFinishGoodsCode];
        }
        if (result.isSucc) {
            NSDictionary *params = [weakSelf _checkIsLoginAndUploadToServerWithReceipt:result.data goodsCode:goodsCode transactionId:result.transaction_id];
            checkOutBlock(goodsCode, result.transaction_id, result.msg, YES, params);
        } else {
            checkOutBlock(goodsCode, result.transaction_id, result.msg, NO, nil);
        }
    }];
#endif
}

- (NSDictionary *)_checkIsLoginAndUploadToServerWithReceipt:(NSData *)receipt goodsCode:(NSString *)goodsCode transactionId:(NSString *)transactionId {
    
   NSLog(@"uploaReceiptToServerWithReceipt %@",receipt);
   NSString *encodeStr = [receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
   NSMutableDictionary *dict = [NSMutableDictionary dictionary];
   [dict setValue:encodeStr forKey:@"payload"];
   [dict setValue:goodsCode forKey:@"goodsCode"];
   [dict setValue:transactionId forKey:@"transactionId"];
   [dict setValue:transactionId forKey:@"transactionCode"];
//   NSString *jsonString = [self _convertToJsonData:dict];
//   NSLog(@"请求服务端jsonString %@", jsonString);
   NSLog(@"请求服务端params %@", dict);
   NSLog(@"请求服务端applicationUsername %@", [self getUnFinishGoodsCode]);
   
   return dict;
}

- (NSString *)_convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if(!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end
