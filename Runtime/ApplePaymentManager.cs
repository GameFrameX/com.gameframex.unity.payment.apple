// GameFrameX 组织下的以及组织衍生的项目的版权、商标、专利和其他相关权利均受相应法律法规的保护。使用本项目应遵守相关法律法规和许可证的要求。
// 
// 本项目主要遵循 MIT 许可证和 Apache 许可证（版本 2.0）进行分发和使用。许可证位于源代码树根目录中的 LICENSE 文件。
// 
// 不得利用本项目从事危害国家安全、扰乱社会秩序、侵犯他人合法权益等法律法规禁止的活动！任何基于本项目二次开发而产生的一切法律纠纷和责任，我们不承担任何责任！

using System.Collections.Generic;
using GameFrameX.Payment.Runtime;

namespace GameFrameX.Payment.Apple.Runtime
{
    [UnityEngine.Scripting.Preserve]
    public sealed class ApplePaymentManager : BasePaymentManager
    {
        [UnityEngine.Scripting.Preserve]
        public ApplePaymentManager()
        {
        }


        /// <summary>
        /// 初始化
        /// </summary>
        /// <param name="isDebug">是否是沙盒模式</param>
        /// <param name="isClientVerify">是否执行客户端验证购买成功，如果是强联网验证。不需要开启，设置为false，进行服务器验证</param>
        [UnityEngine.Scripting.Preserve]
        public override void Init(bool isDebug = false, bool isClientVerify = false)
        {
            ApplePayStoreKit.Instance.Initialize(isDebug, isClientVerify);
        }

        /// <summary>
        /// 支付系统是否准备好
        /// </summary>
        /// <returns>准备好返回true，否则返回false</returns>
        [UnityEngine.Scripting.Preserve]
        public override bool IsReady()
        {
            return ApplePayStoreKit.Instance.IsReady();
        }

        /// <summary>
        /// 查询购买记录
        /// </summary>
        /// <param name="productType">产品类型，inapp/subs</param>
        [UnityEngine.Scripting.Preserve]
        public override void QueryPurchases(string productType)
        {
            ApplePayStoreKit.Instance.QueryPurchases(productType);
        }

        /// <summary>
        /// 消耗购买
        /// </summary>
        /// <param name="purchaseToken">购买令牌</param>
        [UnityEngine.Scripting.Preserve]
        public override void ConsumePurchase(string purchaseToken)
        {
            ApplePayStoreKit.Instance.ConsumePurchase(purchaseToken);
        }

        /// <summary>
        /// 购买 一次性商品
        /// </summary>
        /// <param name="productId">产品ID或SKU</param>
        /// <param name="offerToken">订阅优惠令牌，仅订阅商品需要</param>
        /// <param name="orderId">订单ID</param>
        /// <param name="obfuscatedProfileId">自定义数据</param>
        [UnityEngine.Scripting.Preserve]
        public override void BuyInApp(string productId, string orderId, string offerToken = "", string obfuscatedProfileId = "")
        {
            ApplePayStoreKit.Instance.PurchaseWithAllParams(productId, "inapp", orderId, offerToken, obfuscatedProfileId);
        }

        /// <summary>
        /// 购买 订阅商品
        /// </summary>
        /// <param name="productId">产品ID或SKU</param>
        /// <param name="offerToken">订阅优惠令牌，仅订阅商品需要</param>
        /// <param name="orderId">订单ID</param>
        /// <param name="obfuscatedProfileId">自定义数据</param>
        [UnityEngine.Scripting.Preserve]
        public override void BuySubs(string productId, string orderId, string offerToken = "", string obfuscatedProfileId = "")
        {
            ApplePayStoreKit.Instance.PurchaseWithAllParams(productId, "subs", orderId, offerToken, obfuscatedProfileId);
        }

        /// <summary>
        /// 购买
        /// </summary>
        /// <param name="productId">产品ID或SKU</param>
        /// <param name="productType">产品类型，inapp/subs</param>
        /// <param name="offerToken">订阅优惠令牌，仅订阅商品需要</param>
        /// <param name="orderId">订单ID</param>
        /// <param name="obfuscatedProfileId">自定义数据</param>
        [UnityEngine.Scripting.Preserve]
        public override void Buy(string productId, string productType, string orderId, string offerToken = "", string obfuscatedProfileId = "")
        {
            ApplePayStoreKit.Instance.PurchaseWithAllParams(productId, productType, orderId, offerToken, obfuscatedProfileId);
        }

        /// <summary>
        /// 设置预加载的预定义商品ID,用于预加载缓存,注意：此方法必须在Initialize()之前调用
        /// </summary>
        /// <param name="inAppProductIds">内购商品ID列表</param>
        /// <param name="subsProductIds">订阅商品ID列表</param>
        [UnityEngine.Scripting.Preserve]
        public override void SetPredefinedProductIds(List<string> inAppProductIds, List<string> subsProductIds)
        {
            ApplePayStoreKit.Instance.SetPredefinedProductIds(inAppProductIds, subsProductIds);
        }
    }
}