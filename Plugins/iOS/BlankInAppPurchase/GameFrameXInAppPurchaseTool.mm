//
//  GameFrameXInAppPurchaseTool.mm
//
//  Created by GameframeX(AlianBlank) on 2025/7/31.
//  https://github.com/gameframex
//  https://github.com/alianblank
//


#import "GameFrameXInAppPurchaseTool.h"

@interface GameFrameXInAppPurchaseTool ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

/**
 *  商品字典
 */
@property(nonatomic,strong)NSMutableDictionary *productDict;

/**
 通知对象
 */
@property(nonatomic,strong)NSNotificationCenter* notify;

@property (nonatomic,strong)NSString*checkURL ;

/**
 是否是沙盒模式
 */
@property(nonatomic,assign) BOOL isDebug;

@end

@implementation GameFrameXInAppPurchaseTool


    //单例
static GameFrameXInAppPurchaseTool *storeTool;

    //单例
+(GameFrameXInAppPurchaseTool *)defaultTool{
    if(!storeTool){
        storeTool = [GameFrameXInAppPurchaseTool new];
        [storeTool setup];
    }
    return storeTool;
}


/**
 设置是否是沙盒模式

 @param isDebug 是否是沙盒模式
 */
- (void)setDebug:(BOOL)isDebug{
    
    [self setIsDebug:isDebug];
    if ([self isDebug]) {
        [self setCheckURL: @"https://sandbox.itunes.apple.com/verifyReceipt"];
    }else{
        [self setCheckURL: @"https://buy.itunes.apple.com/verifyReceipt"];
    }
}

#pragma mark  初始化
/**
 *  初始化
 */
-(void)setup{
    [self setDebug:NO];
    self.CheckAfterPay = YES;
    _notify = [NSNotificationCenter defaultCenter];
        // 设置购买队列的监听器
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark 询问苹果的服务器能够销售哪些商品
/**
 *  询问苹果的服务器能够销售哪些商品
 */
- (void)requestProductsWithProductArray:(NSArray *)products
{
    NSLog(@"开始请求可销售商品");
    
        // 能够销售的商品
    NSSet *set = [NSSet setWithArray:products];
    
        // "异步"询问苹果能否销售
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    
    request.delegate = self;
    
        // 启动请求
    [request start];
}

#pragma mark 获取询问结果，成功采取操作把商品加入可售商品字典里
/**
 *  获取询问结果，成功采取操作把商品加入可售商品字典里
 *
 *  @param request  请求内容
 *  @param response 返回的结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"获取询问结果，成功采取操作把商品加入可售商品字典里");
    if (self.productDict == nil) {
        self.productDict = [NSMutableDictionary dictionaryWithCapacity:response.products.count];
    }
    
    NSMutableArray *productArray = [NSMutableArray array];
    
    for (SKProduct *product in response.products) {
        NSLog(@"%@", product.productIdentifier);
            // 填充商品字典
        [self.productDict setObject:product forKey:product.productIdentifier];
        
        [productArray addObject:product];
    }
        //通知代理
    
    
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:productArray forKey:@"value"];
    
    [self.notify postNotificationName:IAPToolGotProducts_NAME object:nil userInfo:dict ];
}

#pragma mark - 用户决定购买商品
/**
 *  用户决定购买商品
 *
 *  @param productID 商品ID
 */
- (void)Buy:(NSString *)productId withPayMentType:(NSString *)paymentType withObfuscatedAccountId:(NSString *)obfuscatedAccountId withObfuscatedProfileId:(NSString *)obfuscatedProfileId withOfferToken:(NSString *)offerToken;
{
    SKProduct *product = self.productDict[productId];
    if(product==nil){
        NSLog(@"Not Found The productID:%@ ",productId);
        return;
    }
    // 使用SKMutablePayment来支持自定义数据
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];

    // 使用obfuscatedAccountId构建可逆的UUID
    if (obfuscatedAccountId && obfuscatedAccountId.length > 0) {
        NSString *reversibleUUID = [self uuidFromLongLong:[obfuscatedAccountId longLongValue]];
        payment.applicationUsername = reversibleUUID;
        NSLog(@"Setting reversible UUID for purchase: %@", reversibleUUID);
    }
    
    // 去收银台排队，准备购买(异步网络)
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKPaymentTransaction Observer
#pragma mark 购买队列状态变化,,判断购买状态是否成功
/**
 *  监测购买队列的变化
 *
 *  @param queue        队列
 *  @param transactions 交易
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
        // 处理结果
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"队列状态变化 %@", transaction);
            // 如果小票状态是购买完成
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
                //NSLog(@"购买完成 %@", transaction.payment.productIdentifier);
            
            if(self.CheckAfterPay){
                    //需要向苹果服务器验证一下
                    //通知代理
                NSMutableDictionary* dict =[NSMutableDictionary new];
                [dict setObject:transaction.payment.productIdentifier forKey:@"value"];
                [self.notify postNotificationName:IAPToolBeginCheckingdWithProductID_NAME object:nil userInfo:dict];
                    //                [self.delegate IAPToolBeginCheckingdWithProductID:transaction.payment.productIdentifier];
                    // 验证购买凭据
                [self verifyPruchaseWithID:transaction.payment.productIdentifier];
            }else{
                    //不需要向苹果服务器验证
                    //通知代理
                    //                [self.delegate IAPToolBoughtProductSuccessedWithProductID:transaction.payment.productIdentifier
                    //                                                                    andInfo:nil];
                NSMutableDictionary* dict =[NSMutableDictionary new];
                [dict setObject:transaction.payment.productIdentifier forKey:@"value"];
                [self.notify postNotificationName:IAPToolBoughtProductSuccessedWithProductID_NAME object:nil userInfo:dict];
            }
                // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        } else if (SKPaymentTransactionStateRestored == transaction.transactionState) {
                //NSLog(@"恢复成功 :%@", transaction.payment.productIdentifier);
            
                // 通知代理
                //            [self.delegate IAPToolRestoredProductID:transaction.payment.productIdentifier];
            NSMutableDictionary* dict =[NSMutableDictionary new];
            [dict setObject:transaction.payment.productIdentifier forKey:@"value"];
            [self.notify postNotificationName:IAPToolRestoredProductID_NAME object:nil userInfo:dict];
                // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (SKPaymentTransactionStateFailed == transaction.transactionState){
            
                // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                //NSLog(@"交易失败");
                //            [self.delegate IAPToolCanceldWithProductID:transaction.payment.productIdentifier];
            NSMutableDictionary* dict =[NSMutableDictionary new];
            [dict setObject:transaction.payment.productIdentifier forKey:@"value"];
            [self.notify postNotificationName:IAPToolCanceldWithProductID_NAME object:nil userInfo:dict];
            
        }else if(SKPaymentTransactionStatePurchasing == transaction.transactionState){
            NSLog(@"正在购买");
        }else{
            NSLog(@"state:%ld",(long)transaction.transactionState);
            NSLog(@"已经购买");
                // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

#pragma mark - 恢复商品
/**
 *  恢复商品
 */
- (void)restorePurchase
{
    NSLog(@"恢复商品");
        // 恢复已经完成的所有交易.（仅限永久有效商品）
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark 验证购买凭据
/**
 *  验证购买凭据
 *
 *  @param ProductID 商品ID
 */
- (void)verifyPruchaseWithID:(NSString *)ProductID
{
        // 验证凭据，获取到苹果返回的交易凭据
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
        // 发送网络POST请求，对购买凭据进行验证
        //In the test environment, use https://sandbox.itunes.apple.com/verifyReceipt
        //In the real environment, use https://buy.itunes.apple.com/verifyReceipt
        // Create a POST request with the receipt data.
    NSURL *url = [NSURL URLWithString:[self checkURL]];
    
    NSLog(@"checkURL:%@",[self checkURL]);
    
        // 国内访问苹果服务器比较慢，timeoutInterval需要长一点
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0f];
    
    request.HTTPMethod = @"POST";
    
        // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
        // 传输的是BASE64编码的字符串
    /**
     BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
     BASE64是可以编码和解码的
     */
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = payloadData;
    
        // 提交验证请求，并获得官方的验证JSON结果
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        // 官方验证结果为空
    if (result == nil) {
            //NSLog(@"验证失败");
            //验证失败,通知代理
        NSMutableDictionary* dict =[NSMutableDictionary new];
        [dict setObject:result forKey:@"value"];
        [dict setObject:ProductID forKey:@"ProductID"];
        [self.notify postNotificationName:IAPToolCheckFailedWithProductID_NAME object:nil userInfo:dict];
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result
                                                         options:NSJSONReadingAllowFragments error:nil];
    
        //NSLog(@"RecivedVerifyPruchaseDict：%@", dict);
    
    if (dict != nil) {
            // 验证成功,通知代理
        NSMutableDictionary* paramdict =[NSMutableDictionary new];
        [paramdict setObject:dict forKey:@"value"];
        [paramdict setObject:ProductID forKey:@"ProductID"];
        [self.notify postNotificationName:IAPToolBoughtProductSuccessedWithProductID_NAME object:nil userInfo:paramdict];
        
    }else{
        
            //验证失败,通知代理
        NSMutableDictionary* paramdict =[NSMutableDictionary new];
        [paramdict setObject:result forKey:@"value"];
        [paramdict setObject:ProductID forKey:@"ProductID"];
        [self.notify postNotificationName:IAPToolCheckFailedWithProductID_NAME object:nil userInfo:paramdict];
        
            //        [self.delegate IAPToolCheckFailedWithProductID:ProductID
            //                                                 andInfo:result];
    }
}

#pragma mark - UUID Generation
/**
 * 基于obfuscatedAccountId生成可逆的UUID
 * 使用long填充UUID前8位，后面用0补充
 */
- (NSString *)uuidFromLongLong:(long long)value {
    // 1. 将long long转换为8字节数组（小端模式，与C#保持一致）
    uint8_t longBytes[8];
    for (int i = 0; i < 8; i++) {
        longBytes[i] = (value >> (8 * i)) & 0xFF;
    }
    
    // 2. 构造16字节的UUID数组（前8字节为long值，后8字节填充0）
    uint8_t uuidBytes[16] = {0}; // 初始化所有字节为0
    memcpy(uuidBytes, longBytes, 8); // 复制前8字节
    
    // 3. 从字节数组创建NSUUID
    return [[[NSUUID alloc] initWithUUIDBytes:uuidBytes] UUIDString];
}
@end
