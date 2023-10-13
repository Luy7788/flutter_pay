//
//  InAppPurTool.m
//  pay_sdk_plugin
//
//  Created by Luy on 2020/10/29.
//

#define NSLog(format,...) printf("%s\n",[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])

#import "InAppPurTool.h"

#ifdef IapPay

@interface InAppPurTool ()<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    
    NSString *_currentProId;
}

@property(nonatomic, copy) InAppPurCompletionHandler iapCompletedBlock;
@property(nonatomic, copy) NSString *applicationUsername;

@property(nonatomic, strong) SKPaymentTransaction *currentTransaction;
@end

@implementation InAppPurTool

+ (instancetype)sharedInAppPurTool {
    static InAppPurTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[super allocWithZone:NULL] init];
    });
    return tool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [InAppPurTool sharedInAppPurTool];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [InAppPurTool sharedInAppPurTool];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [InAppPurTool sharedInAppPurTool];
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadReceiptToServerDidSuccessNotification:) name:InAppPurUploadReceiptToServerDidSuccessKey object:nil];
    }
    return self;
}

/**
 发起支付
 
 @param productId 内购商品ID
 @param applicationUsername 用户信息
 @param finishedBlock 回调
 */
+ (void)hy_iapWithProductId:(NSString *)productId
        applicationUsername:(NSString *)applicationUsername
              finishedBlock:(InAppPurCompletionHandler)finishedBlock {
    [[InAppPurTool sharedInAppPurTool] hy_iapWithProductId:productId applicationUsername:applicationUsername finishedBlock:finishedBlock];
}

/**
 app刚进入前台时使用这个处理监听事件
 
 @param finishedBlock 内购完成时的回调，之后可以上传交易凭证了
 */
+ (void)hy_applicationIapWithFinishedBlock:(InAppPurCompletionHandler)finishedBlock {
    
    [[InAppPurTool sharedInAppPurTool] hy_applicationIapWithFinishedBlock:finishedBlock];
}

+ (SKPaymentTransaction *)getCurrentTransaction {
    return [InAppPurTool sharedInAppPurTool].currentTransaction;
}

- (void)dealloc
{
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
}

/**
 发起支付
 
 @param productId 内购商品ID
 @param applicationUsername 用户信息
 @param finishedBlock 回调
 */
- (void)hy_iapWithProductId:(NSString *)productId
        applicationUsername:(NSString *)applicationUsername
              finishedBlock:(InAppPurCompletionHandler)finishedBlock {
    
    self.iapCompletedBlock = finishedBlock; // 设置回调
    self.applicationUsername = applicationUsername; // 跟用户信息关联
    
    // 不在这里添加监听，应该在a p -p启动的时候就监听
    //    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    _currentProId = productId;
    if([SKPaymentQueue canMakePayments]){
        [self requestProductId:productId];
    }else{
        NSLog(@"不允许程序内付费");
        if (self.iapCompletedBlock) {
            self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:nil msg:@"用户的苹果ID不允许应用内付费" transactionId:nil]);
        }
    }
}

/** 关闭交易: 不在这里关闭交易了：上传完凭证才关闭  */
- (void)closeTransaction:(SKPaymentTransaction *)transaction {
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)clearAllTransations {
    NSArray *pendingTrans = [[SKPaymentQueue defaultQueue] transactions];
    for (int k = 0; k < pendingTrans.count; k++) {
        NSLog(@"clearAllTransations %@", pendingTrans[k]);
        [[SKPaymentQueue defaultQueue] finishTransaction:pendingTrans[k]];
    }
}


//去苹果服务器请求商品
- (void)requestProductId:(NSString *)productId{
    NSLog(@"-------------请求对应的产品信息----------------");
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    NSSet *nsset = [NSSet setWithObjects:productId, nil];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

#pragma mark - <SKProductsRequestDelegate>
// Sent immediately before -requestDidFinish:
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0) {
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *products = response.products;
    if([products count] == 0){
        NSLog(@"未找到商品");
        if (self.iapCompletedBlock) {
            self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:_currentProId msg:@"未找到商品" transactionId:nil]);
        }
//        [KKToast hy_showToast:@"未找到商品"];
        NSLog(@"--------------未找到该商品------------------");
        return;
    }
    
    //   1.取出用户选中的商品
    SKProduct *product = nil;
    for (SKProduct *pro in products) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        /* 填写商品id */
        if([pro.productIdentifier isEqualToString:_currentProId]){
            product = pro;
            break;
        }
    }
    
    if (!product) {
        if (self.iapCompletedBlock) {
            self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:_currentProId msg:@"未找到该商品" transactionId:nil]);
        }
        return;
    }
    
    // 创建制服票据对象
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = self.applicationUsername;
    // 添加到制服队列
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    // 恢复制服 监听
    //    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

//请求失败: 这里容易报错：无法连接到i s
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    if (self.iapCompletedBlock) {
        
        self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:error msg:error.localizedDescription transactionId:nil]);
    }
    NSLog(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"------------反馈信息结束-----------------");
}

#pragma mark - <SKPaymentTransactionObserver>
/// 当制服状态发生改变时,会调用这个方法
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    //    注意在模拟器上测试,交易永远都是失败的
    for (SKPaymentTransaction *tran in transactions) {
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                
                // 发送到苹果服务器验证凭证：不再验证购买，而是让后台做这件事情
                self.currentTransaction = tran;
                NSLog(@"tran.payment.applicationUsername ==> %@",tran.payment.applicationUsername);
                [self callbackToServerWithTransaction:tran];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                // 恢复购买
                [self restoreTransaction:tran];
            }
                break;
                
            case SKPaymentTransactionStateDeferred: {
                NSLog(@"SKPaymentTransactionStateDeferred：The transaction is in the queue, but its final status is pending external action.");
                
                if (self.iapCompletedBlock) {
                    self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:@"SKPaymentTransactionStateDeferred" msg:@"购买失败" transactionId:nil]);
                }
            }
                break;
                
            case SKPaymentTransactionStateFailed: {
                NSLog(@"SKPaymentTransactionStateFailed");
                [self closeTransaction:tran];
                
                // 后面有一个点来区别
                if (self.iapCompletedBlock) {
                    self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:_currentProId msg:@"购买失败" transactionId:nil]);
                }
            }
                break;
            default:
                break;
        }
    }
}

/// 恢复购买
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %zd", queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        NSLog(@"%@",purchasedItemIDs);
    }
}

/// 恢复购买
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    [self closeTransaction:transaction];
    
    // 恢复购买 暂不处理
    
    // 恢复购买 监听
    //    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - 回调给后台
- (void)callbackToServerWithTransaction:(SKPaymentTransaction *)tran {
    //从沙盒中获取交易凭证
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    [self completeTransaction:tran receiptData:receiptData];
}

/**
 app刚进入前台时使用这个处理监听事件
 
 @param finishedBlock 内购完成时的回调，之后可以上传交易凭证了
 */
- (void)hy_applicationIapWithFinishedBlock:(InAppPurCompletionHandler)finishedBlock {
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    
    self.iapCompletedBlock = finishedBlock;
}

#pragma mark - notification
- (void)uploadReceiptToServerDidSuccessNotification:(NSNotification *)notification {

    // 上报成功
    if (notification.object != nil && [notification.object isKindOfClass:[NSString class]]) {
        NSString *goodsCode = (NSString*)[notification object]; 
        NSLog(@"received restored transactions: %zd", queue.transactions.count);
        for (SKPaymentTransaction *transaction in queue.transactions) {
            NSString *productID = transaction.payment.productIdentifier;
            if (goodsCode == productID) {
                [self closeTransaction:transaction];
                return;
            }
        }
    }
    [self closeTransaction:self.currentTransaction];

}


//交易结束,当交易结束后还要去appstore上验证支付信息是否都正确,只有所有都正确后,我们就可以给用户方法我们的虚拟物品了。
- (void)completeTransaction:(SKPaymentTransaction *)transaction receiptData:(NSData *)receiptData {
//    // 验证凭据，获取到苹果返回的交易凭据
//    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
//    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
//    // 从沙盒中获取到购买凭据
//    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    //发送POST请求，对购买凭据进行验证
    //测试验证地址：https://sandbox.itunes.apple.com/verifyReceipt
    //正式验证地址：https://buy.itunes.apple.com/verifyReceipt
    NSString *AppStore_URL;
    if(self.isSandBox == YES){
        AppStore_URL = @"https://sandbox.itunes.apple.com/verifyReceipt";
    } else {
        AppStore_URL = @"https://buy.itunes.apple.com/verifyReceipt";
    }
    NSLog(@"验证IAP地址====%@",AppStore_URL);
    NSURL *url = [NSURL URLWithString:AppStore_URL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    urlRequest.HTTPMethod = @"POST";
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    _receipt = encodeStr;
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPBody = payloadData;

    NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];

    if (result == nil) {
        NSLog(@"验证失败");
        if (self.iapCompletedBlock) {
            self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:_currentProId msg:@"购买失败" transactionId:nil]);
        }
        return;
    }

    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"请求成功后的数据:%@",dic);
    //这里可以通过判断 state == 0 验证凭据成功，然后进入自己服务器二次验证，,也可以直接进行服务器逻辑的判断。
    //本地服务器验证成功之后别忘了 [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    NSString *productId = transaction.payment.productIdentifier;
    NSString *applicationUsername = transaction.payment.applicationUsername;

    NSLog(@"applicationUsername===%@",applicationUsername);
    NSLog(@"payment.productIdentifier===%@",productId);

    if (dic != nil) {
        NSDictionary *receipt = dic[@"receipt"];
        NSNumber *status = dic[@"status"];
        if (status != nil && status.integerValue == 21007) {
            if(self.isSandBox == NO) {
                //如果是线上报21007,可能是审核测试？切换沙箱环境重新校验
                self.isSandBox = YES;
                [self completeTransaction:transaction receiptData:receiptData];
                return;
            }
            if (self.iapCompletedBlock) {
                self.iapCompletedBlock([InAppPurResult resultWithResult:@"0" data:_currentProId msg:@"内购错误21007，请联系客服" transactionId:nil]);
            }
            return;
        }
        NSArray *in_app = receipt[@"in_app"];
        NSString *transaction_id;
        NSString *product_id;
        BOOL isArray = NO;
        NSMutableArray *transactionArray = [[NSMutableArray alloc] init];
        InAppPurResult *inappPurResult;
        if (in_app != nil && in_app.count > 0) {
            if (in_app.count > 1) {
                //是否返回多个票据
                isArray = YES;
            }
            for (NSDictionary *item in in_app) {
                transaction_id = item[@"transaction_id"];
                product_id = item[@"product_id"];
                //服务器二次验证
                inappPurResult = [InAppPurResult resultWithResult:@"1" data:receiptData msg:@"苹果支付完成" transactionId:transaction_id];
               if (self.iapCompletedBlock && isArray == NO) {
                   inappPurResult.transationArray = transactionArray;
                   self.iapCompletedBlock(inappPurResult);
               } else {
                  [transactionArray addObject: @{@"transaction_id":transaction_id, @"product_id":product_id}];
               }
            }
            
            if (isArray == YES) {
                //多个票据的话返回数组
                if (self.iapCompletedBlock) {   
                   inappPurResult.transationArray = transationArray;
                   self.iapCompletedBlock(inappPurResult);
               } 
            }

        }
    }
}


@end

#endif
