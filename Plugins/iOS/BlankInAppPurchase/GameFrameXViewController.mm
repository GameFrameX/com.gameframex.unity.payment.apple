//
//  GameFrameXViewController.mm
//
//  Created by GameframeX(AlianBlank) on 2025/7/31.
//  https://github.com/gameframex
//  https://github.com/alianblank
//

#import "GameFrameXViewController.h"
#import "GameFrameXInAppPurchaseTool.h"

@interface GameFrameXViewController ()
@property (nonatomic,strong) NSMutableArray *productArray;
@property (nonatomic,strong) NSNotificationCenter* notify;
@property (nonatomic,assign) BOOL inited;

@end

@implementation GameFrameXViewController

// 消息码常量定义

// 初始化相关
#define InitSuccess 1000
#define InitFail 1001

// 查询商品相关
#define QueryProductsSuccess 2000
#define QueryProductsFail 2001

// 购买相关
#define PurchaseSuccess 3000
#define PurchaseFail 3001
#define PurchaseCancel 3002

// 购买检查相关
#define PurchaseCheckSuccess 3100
#define PurchaseCheckFail 3101

// 消耗相关
#define ConsumeSuccess 4000
#define ConsumeFail 4001

// 查询购买历史相关
#define QueryPurchasesSuccess 5000
#define QueryPurchasesFail 5001


// 支付系统是否准备好
-(BOOL)isReady{
    return [self inited];
}

-(NSMutableArray *)productArray{
    if(!_productArray){
        _productArray = [NSMutableArray array];
    }
    return _productArray;
}

/**
 开始
 
 @param productIDs 产品ID的Json数组的字符串形式
 @param isDebug 是否是沙盒模式
 */
- (void)initialize:(NSArray*) allProductIds withDebug:(BOOL)isDebug withClientVerify:(BOOL)isClientVerifyBool {
    _notify= [NSNotificationCenter defaultCenter];
    //获取单例
    GameFrameXInAppPurchaseTool *IAPTool = [GameFrameXInAppPurchaseTool defaultTool];
    // 设置是否是沙盒模式
    [IAPTool setDebug:isDebug];
    //购买后，向苹果服务器验证一下购买结果。默认为YES。不建议关闭
    IAPTool.CheckAfterPay = isClientVerifyBool;
    //设置代理
    [self thisAddObservers];
    //向苹果询问哪些商品能够购买
    [IAPTool requestProductsWithProductArray:allProductIds];
}

// 监听数据通知
- (void)thisAddObservers{
    
    // 系统错误
    [self.notify addObserver:self selector:@selector(IAPToolSysWrong) name:IAPToolSysWrong_NAME object:nil];
    // 已刷新可购买商品
    [self.notify addObserver:self selector:@selector(IAPToolGotProducts:) name:IAPToolGotProducts_NAME object:nil];
    // 购买成功
    [self.notify addObserver:self selector:@selector(IAPToolBoughtProductSuccessedWithProductID:) name:IAPToolBoughtProductSuccessedWithProductID_NAME object:nil];
    // 取消购买
    [self.notify addObserver:self selector:@selector(IAPToolCanceldWithProductID:) name:IAPToolCanceldWithProductID_NAME object:nil];
    // 重复验证
    [self.notify addObserver:self selector:@selector(IAPToolCheckRedundantWithProductID:) name:IAPToolCheckRedundantWithProductID_NAME object:nil];
    // 购买成功，开始验证购买
    [self.notify addObserver:self selector:@selector(IAPToolBeginCheckingdWithProductID:) name:IAPToolBeginCheckingdWithProductID_NAME object:nil];
    // 验证失败
    [self.notify addObserver:self selector:@selector(IAPToolCheckFailedWithProductID:) name:IAPToolCheckFailedWithProductID_NAME object:nil];
    // 恢复了已购买的商品（永久性商品）
    [self.notify addObserver:self selector:@selector(IAPToolRestoredProductID:) name:IAPToolRestoredProductID_NAME object:nil];
    
}
// 取消监听数据通知
- (void)thisRemoveObservers{
    [self.notify removeObserver:self];
}

-(void)dealloc{
    [self thisRemoveObservers];
}

/**
 * 发送消息给Unity端
 *
 * @param message 要发送的消息内容
 * @param errorCode 错误码，用于标识消息类型或状态
 *
 * 消息格式：错误码|消息内容
 * 例如：1000|初始化成功
 *      3001|购买失败
 *
 * 通过UnitySendMessage调用Unity端的OnMessage方法
 */
-(void)sendMessageToUnity:(NSString *) message withErrorCode:(int)errorCode{
    // 构建包含错误码的消息，使用竖线分隔符
    // 格式：错误码|消息内容
    NSString *messageWithCode = [NSString stringWithFormat:@"%d|%@", errorCode, message];
    
    // 将NSString转换为C字符串
    char * sendMessage = [self stringToChar:messageWithCode];
    
    // 发送消息到Unity端的BlankInAppPurchaseBridgeLink对象的OnMessage方法
    UnitySendMessage(BlankInAppPurchaseBridgeLink, "OnMessage", sendMessage);
}

#pragma mark --------YQInAppPurchaseToolDelegate
//IAP工具已获得可购买的商品
-(void)IAPToolGotProducts:(NSNotification *)user {
    NSMutableArray * products =  [user.userInfo valueForKey:@"value"];

    NSLog(@" 成功获取到可购买的商品  GotProducts:%@",products);
    
    NSMutableArray * productProductList= [NSMutableArray new];
    
    for (SKProduct *product in products){
        
        // 构建包含SKProduct所有字段的JSON对象
        NSMutableDictionary *productDict = [NSMutableDictionary dictionary];
        
        // 基本信息
        [productDict setObject:product.productIdentifier ?: @"" forKey:@"ProductIdentifier"];
        [productDict setObject:product.localizedTitle ?: @"" forKey:@"LocalizedTitle"];
        [productDict setObject:product.localizedDescription ?: @"" forKey:@"LocalizedDescription"];
        [productDict setObject:product.price ?: @0 forKey:@"Price"];
        
        // 价格和货币信息
        [productDict setObject:product.priceLocale.currencyCode ?: @"" forKey:@"CurrencyCode"];
        [productDict setObject:product.priceLocale.currencySymbol ?: @"" forKey:@"CurrencySymbol"];
        [productDict setObject:product.priceLocale.localeIdentifier ?: @"" forKey:@"LocaleIdentifier"];
        
        // iOS 11.2+ 订阅相关字段
        if (@available(iOS 11.2, *)) {
            if (product.subscriptionPeriod) {
                [productDict setObject:@(product.subscriptionPeriod.numberOfUnits) forKey:@"SubscriptionPeriodNumberOfUnits"];
                [productDict setObject:@(product.subscriptionPeriod.unit) forKey:@"SubscriptionPeriodUnit"];
            }
            
            if (product.introductoryPrice) {
                NSMutableDictionary *introPrice = [NSMutableDictionary dictionary];
                [introPrice setObject:product.introductoryPrice.price ?: @0 forKey:@"Price"];
                [introPrice setObject:product.introductoryPrice.priceLocale.currencyCode ?: @"" forKey:@"CurrencyCode"];
                [introPrice setObject:@(product.introductoryPrice.paymentMode) forKey:@"PaymentMode"];
                [introPrice setObject:@(product.introductoryPrice.numberOfPeriods) forKey:@"NumberOfPeriods"];
                if (product.introductoryPrice.subscriptionPeriod) {
                    [introPrice setObject:@(product.introductoryPrice.subscriptionPeriod.numberOfUnits) forKey:@"SubscriptionPeriodNumberOfUnits"];
                    [introPrice setObject:@(product.introductoryPrice.subscriptionPeriod.unit) forKey:@"SubscriptionPeriodUnit"];
                }
                [productDict setObject:introPrice forKey:@"IntroductoryPrice"];
            }
        }
        
        // iOS 12.0+ 折扣信息
        if (@available(iOS 12.0, *)) {
            if (product.discounts && product.discounts.count > 0) {
                NSMutableArray *discountsArray = [NSMutableArray array];
                for (SKProductDiscount *discount in product.discounts) {
                    NSMutableDictionary *discountDict = [NSMutableDictionary dictionary];
                    [discountDict setObject:discount.price ?: @0 forKey:@"Price"];
                    [discountDict setObject:discount.priceLocale.currencyCode ?: @"" forKey:@"CurrencyCode"];
                    [discountDict setObject:discount.identifier ?: @"" forKey:@"Identifier"];
                    [discountDict setObject:@(discount.paymentMode) forKey:@"PaymentMode"];
                    [discountDict setObject:@(discount.numberOfPeriods) forKey:@"NumberOfPeriods"];
                    if (discount.subscriptionPeriod) {
                        [discountDict setObject:@(discount.subscriptionPeriod.numberOfUnits) forKey:@"SubscriptionPeriodNumberOfUnits"];
                        [discountDict setObject:@(discount.subscriptionPeriod.unit) forKey:@"SubscriptionPeriodUnit"];
                    }
                    [discountsArray addObject:discountDict];
                }
                [productDict setObject:discountsArray forKey:@"Discounts"];
            }
        }
        
        // iOS 12.2+ 订阅组信息
        if (@available(iOS 12.2, *)) {
            [productDict setObject:product.subscriptionGroupIdentifier ?: @"" forKey:@"SubscriptionGroupIdentifier"];
        }
        
        // 直接将字典添加到数组中
        [productProductList addObject:productDict];
    }
    self.productArray = products;
    NSData * jsonData=  [NSJSONSerialization  dataWithJSONObject:productProductList options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    // 成功查询到内容
    [self sendMessageToUnity:jsonString withErrorCode:QueryProductsSuccess];
    [self setInited:YES];
}
//支付失败/取消
-(void)IAPToolCanceldWithProductID:(NSNotification *)user {
    NSString* productID = [user.userInfo valueForKey:@"value"];
    [self sendMessageToUnity:productID withErrorCode:PurchaseFail];
    NSLog(@" 购买失败  canceld:%@",productID);
}
//支付成功了，并开始向苹果服务器进行验证（若CheckAfterPay为NO，则不会经过此步骤）
-(void)IAPToolBeginCheckingdWithProductID:(NSNotification *)user {
    NSString* productID = [user.userInfo valueForKey:@"value"];
//    [self.productArray valueForKey:productID];
    [self sendMessageToUnity:productID withErrorCode:PurchaseCheckSuccess];
    NSLog(@" 购买成功，正在验证购买   BeginChecking:%@",productID);
}
//商品被重复验证了
-(void)IAPToolCheckRedundantWithProductID:(NSNotification*)user{
    
    NSString*productID = [user.userInfo valueForKey:@"productID"];
    
    NSLog(@" 重复验证了  CheckRedundant:%@",productID);
}
//商品完全购买成功且验证成功了。（若CheckAfterPay为NO，则会在购买成功后直接触发此方法）
-(void)IAPToolBoughtProductSuccessedWithProductID:(NSNotification*)user {
    NSString * productID = [user.userInfo valueForKey:@"ProductID"];
    NSDictionary * infoDic =[user.userInfo valueForKey:@"value"];
    
//    infoDic 数据结构
//    {
//        environment = Sandbox;
//        receipt =     {
//            "adam_id" = 0;
//            "app_item_id" = 0;
//            "application_version" = 8;
//            "bundle_id" = "com.zilancreative.nsfr";
//            "download_id" = 0;
//            "in_app" =         (
//                            {
//                    "in_app_ownership_type" = PURCHASED;
//                    "is_trial_period" = false;
//                    "original_purchase_date" = "2025-08-04 10:05:00 Etc/GMT";
//                    "original_purchase_date_ms" = 1754301900000;
//                    "original_purchase_date_pst" = "2025-08-04 03:05:00 America/Los_Angeles";
//                    "original_transaction_id" = 2000000975974181;
//                    "product_id" = 13001;
//                    "purchase_date" = "2025-08-04 10:05:00 Etc/GMT";
//                    "purchase_date_ms" = 1754301900000;
//                    "purchase_date_pst" = "2025-08-04 03:05:00 America/Los_Angeles";
//                    quantity = 1;
//                    "transaction_id" = 2000000975974181;
//                }
//            );
//            "original_application_version" = "1.0";
//            "original_purchase_date" = "2013-08-01 07:00:00 Etc/GMT";
//            "original_purchase_date_ms" = 1375340400000;
//            "original_purchase_date_pst" = "2013-08-01 00:00:00 America/Los_Angeles";
//            "receipt_creation_date" = "2025-08-04 10:10:58 Etc/GMT";
//            "receipt_creation_date_ms" = 1754302258000;
//            "receipt_creation_date_pst" = "2025-08-04 03:10:58 America/Los_Angeles";
//            "receipt_type" = ProductionSandbox;
//            "request_date" = "2025-08-04 10:11:00 Etc/GMT";
//            "request_date_ms" = 1754302260476;
//            "request_date_pst" = "2025-08-04 03:11:00 America/Los_Angeles";
//            "version_external_identifier" = 0;
//        };
//        status = 0;
//    }
    
    // 生成购买令牌（iOS中使用transaction ID作为购买令牌）
    NSString *purchaseToken = @"";
    if (infoDic && [infoDic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *receipt = [infoDic objectForKey:@"receipt"];
        if (receipt) {
            NSArray *inApp = [receipt objectForKey:@"in_app"];
            if (inApp && inApp.count > 0) {
                NSDictionary *transaction = [inApp firstObject];
                purchaseToken = [transaction objectForKey:@"transaction_id"] ?: @"";
            }
        }
    }
    
    // 构建购买成功的详细信息
    NSMutableDictionary * product =   [[NSMutableDictionary alloc] init];
    [product setObject:productID forKey:@"ProductId"];
    [product setObject:purchaseToken forKey:@"Receipt"];
    NSData * jsonData=  [NSJSONSerialization  dataWithJSONObject:product options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString *successInfo = [NSString stringWithFormat:@"{\"ProductId\":\"%@\",\"Receipt\":\"%@\",\"Info\":\"%@\"}", productID, purchaseToken, infoDic ?: @""];
    [self sendMessageToUnity:jsonString withErrorCode:PurchaseSuccess];
    NSLog(@"BoughtSuccessed:%@",productID);
    NSLog(@"successedInfo:%@",infoDic);
}
//商品购买成功了，但向苹果服务器验证失败了
//2种可能：
//1，设备越狱了，使用了插件，在虚假购买。
//2，验证的时候网络突然中断了。（一般极少出现，因为购买的时候是需要网络的）
-(void)IAPToolCheckFailedWithProductID:(NSNotification *)user{
    NSString* productID = [user.userInfo valueForKey:@"ProductID"];
    // 购买失败
    [self sendMessageToUnity:productID withErrorCode:PurchaseFail];
    // 验证检查失败
    [self sendMessageToUnity:productID withErrorCode:PurchaseCheckFail];
    NSLog(@"验证失败了  CheckFailed:%@",productID);
}
//恢复了已购买的商品（仅限永久性商品）
-(void)IAPToolRestoredProductID:(NSNotification*)user {
    
    NSString*productID = [user.userInfo valueForKey:@"value"];
    UnitySendMessage(BlankInAppPurchaseBridgeLink, "Restored", [self stringToChar: productID]);
    
    // 同时发送查询购买记录的结果
    NSString *purchaseRecord = [NSString stringWithFormat:@"[{\"productId\":\"%@\",\"purchaseState\":1,\"purchaseTime\":%ld}]", productID, (long)[[NSDate date] timeIntervalSince1970] * 1000];
    [self sendMessageToUnity:purchaseRecord withErrorCode:QueryPurchasesSuccess];
    NSLog(@"成功恢复了商品（已打印） Restored:%@",productID);
}
//内购系统错误了
-(void)IAPToolSysWrong {
    [self sendMessageToUnity:@"内购系统出错" withErrorCode:InitFail];
    NSLog(@"内购系统出错  SysWrong");
    //    [SVProgressHUD showErrorWithStatus:@"内购系统出错"];
}


-(char *)stringToChar:(NSString *)str{
    
    const char *charstr = [str UTF8String];
    // alloc
    char *result = (char*)malloc(strlen(charstr)+1);
    // copy
    strcpy(result, charstr);
    
    return result;
}


#pragma mark --------Functions



//恢复已购买的商品
-(void)restoreProduct{
    //直接调用
    [[GameFrameXInAppPurchaseTool defaultTool] restorePurchase];
}

//购买商品
-(void)Buy:(NSString *)productId withPayMentType:(NSString *)paymentType withObfuscatedAccountId:(NSString *)obfuscatedAccountId withObfuscatedProfileId:(NSString *)obfuscatedProfileId withOfferToken:(NSString *)offerToken{
    
    if ([self inited] == NO) {
        NSLog(@"没有初始化完成.请稍后");
        return;
    }
    
    [[GameFrameXInAppPurchaseTool defaultTool] Buy:productId withPayMentType:paymentType withObfuscatedAccountId:obfuscatedAccountId withObfuscatedProfileId:obfuscatedProfileId withOfferToken:offerToken];
}
@end
