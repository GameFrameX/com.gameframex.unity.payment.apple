//
//  GameFrameXInAppPurchaseTool.h
//
//  Created by GameframeX(AlianBlank) on 2025/7/31.
//  https://github.com/gameframex
//  https://github.com/alianblank
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

    // 系统错误
#define IAPToolSysWrong_NAME @"IAPToolSysWrong_NAME"
    // 已刷新可购买商品
#define IAPToolGotProducts_NAME @"IAPToolGotProducts_NAME"
    // 购买成功
#define IAPToolBoughtProductSuccessedWithProductID_NAME @"IAPToolBoughtProductSuccessedWithProductID_NAME"
    // 取消购买
#define IAPToolCanceldWithProductID_NAME @"IAPToolCanceldWithProductID_NAME"
    // 购买成功，开始验证购买
#define IAPToolBeginCheckingdWithProductID_NAME @"IAPToolBeginCheckingdWithProductID_NAME"
    // 重复验证
#define IAPToolCheckRedundantWithProductID_NAME @"IAPToolCheckRedundantWithProductID_NAME"
    // 验证失败
#define IAPToolCheckFailedWithProductID_NAME @"IAPToolCheckFailedWithProductID_NAME"
    // 恢复了已购买的商品（永久性商品）
#define IAPToolRestoredProductID_NAME @"IAPToolRestoredProductID_NAME"

#pragma mark --------GameFrameXInAppPurchaseTool--内购工具
/**
 *  内购工具
 */
@interface GameFrameXInAppPurchaseTool : NSObject

typedef void(^BoolBlock)(BOOL successed,BOOL result);

typedef void(^DicBlock)(BOOL successed,NSDictionary *result);
/**
 *  购买完后是否在iOS端向服务器验证一次,默认为YES
 */
@property(nonatomic)BOOL CheckAfterPay;

/**
 *  单例
 *
 *  @return GameFrameXInAppPurchaseTool
 */
+(GameFrameXInAppPurchaseTool *)defaultTool;


/**
 设置是否是沙盒模式

 @param isDebug 是否是沙盒模式
 */
- (void)setDebug:(BOOL)isDebug;

/**
 *  询问苹果的服务器能够销售哪些商品
 *
 *  @param products 商品ID的数组
 */
- (void)requestProductsWithProductArray:(NSArray *)products;

/**
 *  用户决定购买商品
 *
 *  @param productID 商品ID
 */
-(void)Buy:(NSString *)productId withPayMentType:(NSString *)paymentType withObfuscatedAccountId:(NSString *)obfuscatedAccountId withObfuscatedProfileId:(NSString *)obfuscatedProfileId withOfferToken:(NSString *)offerToken;


/**
 *  恢复商品（仅限永久有效商品）
 */
- (void)restorePurchase;

@end
