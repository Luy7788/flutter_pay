//
//  PaySdkManager.m
//  pay_sdk_plugin
//
//  Created by Luy on 2020/10/29.
//

#import "PaySdkManager.h"
#import <StoreKit/StoreKit.h>
#import "InAppPurTool.h"

#define kAppPayUnFinishOrderKey @"UnFinishOrder"

#define NSLog(format,...) printf("%s\n",[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])


@interface PaySdkManager () {
    NSString *GoodsCode;
}
@property (nonatomic, assign) NSTimeInterval receiptTime;
//@property (nonatomic, copy) NSString *applicationUsername;
@property (nonatomic, copy) PayFinifshBlock finishBlock;

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
    //是否允许内购
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"用户允许内购");
        return YES;
    }else{
        NSLog(@"用户不允许内购");
        return NO;
    }
}

- (void)setupIap:(bool)isSandBox{
    [InAppPurTool sharedInAppPurTool].isSandBox = isSandBox;
}

- (void)payAction:(NSString *)goodsCode
           finish:(PayFinifshBlock)finishBlock {
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
}

//验证成功后调用
- (void)finishPayAction:(NSString *)goodsCode {
    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurUploadReceiptToServerDidSuccessKey object:nil];
    [self saveUserGoodsCode:nil];
}

- (void)applicationIapWithFinished:(PayFinifshBlock)checkOutBlock {
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
//    return [self _uploaReceiptToServerWithReceipt:receipt productID:productID transactionId:transactionId];
}

//FIXME:TEST
- (void)_uploaReceiptToServerWithReceipt:(NSData *)receipt productID:(NSString *)productID {

    __weak __typeof(self)weakSelf = self;
    NSLog(@"uploaReceiptToServerWithReceipt %@",receipt);

    //获取NSURLSession对象
    NSURLSession *session = [NSURLSession sharedSession];
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.2.8:9999/pay/ios/iap"]];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSString *encodeStr = [receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    //    request.HTTPBody = payloadData;
    //    NSString *payload = [NSString stringWithFormat:@"{\"payload\" : \"%@\"}", encodeStr];
    //    request.HTTPBody = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:encodeStr forKey:@"payload"];
    [dict setValue:productID forKey:@"goodsCode"];
    [dict setValue:@"1000000736118578" forKey:@"transactionId"];
    [dict setValue:@"1000000736118578" forKey:@"transactionCode"];
    NSString *jsonString = [self _convertToJsonData:dict];
    request.HTTPBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"请求服务端request %@", request);
    NSLog(@"请求服务端jsonString %@", jsonString);
    NSLog(@"请求服务端HTTPBody %@", request.HTTPBody);
    NSLog(@"请求服务端applicationUsername %@", [self getUnFinishGoodsCode]);
    //创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            weakSelf.receiptTime = 0;
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            NSLog(@"task data: %@",dic);
            NSNumber *code = dic[@"code"];
            if(code.integerValue == 500){
                weakSelf.receiptTime++;
                if (weakSelf.receiptTime < 5) {
                    // 隔5秒再请求一次 总共请求5次
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self _uploaReceiptToServerWithReceipt:receipt productID:productID];
                    });
                }
            } else {
//                if(code.integerValue == 200) {
                    //验证成功后调用
                    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurUploadReceiptToServerDidSuccessKey object:nil];
                    [weakSelf saveUserGoodsCode:nil];
//                }
            }
        }
        if (response != nil) {
            NSLog(@"task response: %@",response);
        }
        if (error != nil) {
            NSLog(@"task error: %@",response);
            weakSelf.receiptTime++;
            if (weakSelf.receiptTime < 5) {
                // 隔5秒再请求一次 总共请求5次
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self _uploaReceiptToServerWithReceipt:receipt productID:productID];
                });
            }
        }
    }];
    //启动任务
    [task resume];
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
