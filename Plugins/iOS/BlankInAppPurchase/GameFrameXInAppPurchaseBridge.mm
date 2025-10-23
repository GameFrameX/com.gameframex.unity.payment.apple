//
//  GameFrameXInAppPurchaseBridge.mm
//
//  Created by GameframeX(AlianBlank) on 2025/7/31.
//  https://github.com/gameframex
//  https://github.com/alianblank
//

#import <GameFrameXViewController.h>

GameFrameXViewController * instance;

// 合并一次性购买商品和订阅商品的ID
NSMutableArray *allProductIds;

// 查询购买记录
extern "C" void __gfx_iap_query_purchases(char * paymentType) {
    NSLog(@"__gfx_iap_query_purchases called with paymentType: %s", paymentType);
    // iOS内购系统通过恢复购买来获取已购买的永久性商品
    // 对于消费型商品，iOS不保存购买记录
    if (instance != nil) {
        [instance restoreProduct];
    } else {
        // 如果实例不存在，返回空的购买记录
        NSString *messageWithCode = [NSString stringWithFormat:@"%d|[]", 5000];
        UnitySendMessage(BlankInAppPurchaseBridgeLink, "OnMessage", [messageWithCode UTF8String]);
    }
}

// 消费已购买的商品
extern "C" void __gfx_iap_consume(char * purchaseToken) {
    // iOS内购系统中消费型商品购买后自动消费，这里主要用于日志记录
    NSLog(@"__gfx_iap_consume called with purchaseToken: %s", purchaseToken);
    // iOS不需要手动消费，购买完成后自动处理
}

// 初始化
extern "C" void __gfx_iap_init(char * isDebug, char * isClientVerify) {
    NSLog(@"__gfx_iap_init called");
    // 将字符串转换为BOOL类型
    NSString * isDebugString = [NSString stringWithUTF8String:isDebug];
    // 沙盒模式标记
    BOOL isDebugBool = [isDebugString boolValue];
    NSLog(@"Debug mode: %@", isDebugBool ? @"YES" : @"NO");

    // 客户端验证标记
    NSString * isClientVerifyString = [NSString stringWithUTF8String:isClientVerify];
    BOOL isClientVerifyBool = [isClientVerifyString boolValue];
    NSLog(@"Client VerifyBool: %@", isClientVerifyBool ? @"YES" : @"NO");
    if(instance == nil){
        instance = [[GameFrameXViewController alloc] init];
    }
    // 确保allProductIds已初始化
    if (allProductIds == nil) {
        allProductIds = [NSMutableArray array];
    }
    // 请求SKU列表和获取信息
    [instance initialize:allProductIds withDebug:isDebugBool withClientVerify:isClientVerifyBool];
}

// 是否准备好支付系统,返回bool字符串
extern "C" char * __gfx_iap_isReady() {
    BOOL isReady =YES;
    if (instance==nil) {
        isReady = NO;
    }
    isReady = [instance isReady];
    NSString *result = isReady ? @"true" : @"false";
    
    const char *charstr = [result UTF8String];
    char *returnResult = (char*)malloc(strlen(charstr)+1);
    strcpy(returnResult, charstr);
    
    return returnResult;
}

// 发起购买
extern "C" void __gfx_iap_buy(char * productId, char * paymentType, char * obfuscatedAccountId, char * offerToken, char * obfuscatedProfileId) {
    NSLog(@"__gfx_iap_buy called with productId: %s, paymentType: %s", productId, paymentType);
    if (instance == nil) {
        NSLog(@"没有初始化IAP服务");
        return;
    }
    NSString * productIdString =  [NSString stringWithUTF8String:productId];
    NSString * paymentTypeString =  [NSString stringWithUTF8String:paymentType];
    NSString * obfuscatedAccountIdString =  [NSString stringWithUTF8String:obfuscatedAccountId];
    NSString * offerTokenString =  [NSString stringWithUTF8String:offerToken];
    NSString * obfuscatedProfileIdString =  [NSString stringWithUTF8String:obfuscatedProfileId];
    
    // 发起购买
    [instance Buy:productIdString withPayMentType:paymentTypeString withObfuscatedAccountId:obfuscatedAccountIdString withObfuscatedProfileId:obfuscatedProfileIdString withOfferToken:offerTokenString];
}

// 设置预加载的sku列表
extern "C" void __gfx_iap_set_pre_defined_product_ids(char * inAppProductIdString, char * subProductIdString) {
    NSLog(@"__gfx_iap_set_pre_defined_product_ids called");
    
    allProductIds = [NSMutableArray array];
    
    if (inAppProductIdString) {
        NSString *productIdsStr = [NSString stringWithUTF8String:inAppProductIdString];
        NSLog(@"InApp Product IDs: %@", productIdsStr);
        
        // 解析JSON数组
        NSArray *inAppIds = [NSJSONSerialization JSONObjectWithData:[productIdsStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if (inAppIds && [inAppIds isKindOfClass:[NSArray class]]) {
            [allProductIds addObjectsFromArray:inAppIds];
        }
    }
    
    if (subProductIdString) {
        NSString *subProductIdsStr = [NSString stringWithUTF8String:subProductIdString];
        NSLog(@"Subscription Product IDs: %@", subProductIdsStr);
        
        // 解析JSON数组
        NSArray *subIds = [NSJSONSerialization JSONObjectWithData:[subProductIdsStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if (subIds && [subIds isKindOfClass:[NSArray class]]) {
            [allProductIds addObjectsFromArray:subIds];
        }
    }
}

// 恢复已经购买的商品(仅限永久性商品)
extern "C" void __gfx_iap_restore() {
    NSLog(@"__gfx_iap_restore called");
    [instance restoreProduct];
}
