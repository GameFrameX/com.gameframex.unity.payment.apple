//
//  GameFrameXViewController.h
//
//  Created by GameframeX(AlianBlank) on 2025/7/31.
//  https://github.com/gameframex
//  https://github.com/alianblank
//

#import <UIKit/UIKit.h>

// 链接桥的名称
#define BlankInAppPurchaseBridgeLink "BlankInAppPurchaseBridgeLink"

@interface GameFrameXViewController : UIViewController


/**
  初始化SKU列表
 
 @param allProductIds 产品ID
 */
- (void)initialize:(NSArray*) allProductIds withDebug:(BOOL)isDebug withClientVerify:(BOOL)isClientVerifyBool;

/**
 恢复已购买的商品（仅限永久有效商品）
 */
-(void)restoreProduct;

/**
 购买商品
 
 @param productID 产品ID
 */
-(void)Buy:(NSString *)productId withPayMentType:(NSString *)paymentType withObfuscatedAccountId:(NSString *)obfuscatedAccountId withObfuscatedProfileId:(NSString *)obfuscatedProfileId withOfferToken:(NSString *)offerToken;

-(BOOL)isReady;

//
//#if defined (__cplusplus)
//extern "C" {
//#endif
//    // 查询购买记录
//    void __gfx_iap_query_purchases(char * paymentType);
//    // 消费已购买的商品
//    void __gfx_iap_consume(char * purchaseToken);
//    // 初始化
//    void __gfx_iap_init();
//    // 是否准备好支付系统,返回bool 字符串
//    char * __gfx_iap_isReady();
//    // 发起购买
//    void __gfx_iap_buy(char * productId, char * paymentType, char * obfuscatedAccountId,char * offerToken, char * obfuscatedProfileId);
//    // 设置预加载的sku列表
//    void __gfx_iap_set_pre_defined_product_ids(char * inAppProductIdString, char * subProductIdString);
//    // 恢复已经购买的商品(仅限永久性商品)
//    void __gfx_iap_restore();
//#if defined (__cplusplus)
//}
//#endif

@end

