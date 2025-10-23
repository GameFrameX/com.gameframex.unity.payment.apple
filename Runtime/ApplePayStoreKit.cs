// GameFrameX 组织下的以及组织衍生的项目的版权、商标、专利和其他相关权利均受相应法律法规的保护。使用本项目应遵守相关法律法规和许可证的要求。
// 
// 本项目主要遵循 MIT 许可证和 Apache 许可证（版本 2.0）进行分发和使用。许可证位于源代码树根目录中的 LICENSE 文件。
// 
// 不得利用本项目从事危害国家安全、扰乱社会秩序、侵犯他人合法权益等法律法规禁止的活动！任何基于本项目二次开发而产生的一切法律纠纷和责任，我们不承担任何责任！

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using GameFrameX.Runtime;
using UnityEngine;

namespace GameFrameX.Payment.Apple.Runtime
{
    public partial class ApplePayStoreKit : MonoBehaviour
    {
#if UNITY_IOS
        /// <summary>
        /// 查询购买记录
        /// </summary>
        /// <param name="productType">产品类型，inapp/subs</param>
        [DllImport("__Internal")]
        private static extern void __gfx_iap_query_purchases(string productType);

        /// <summary>
        /// 初始化
        /// </summary>
        /// <param name="isDebug">是否是沙盒模式的Bool 字符串</param>
        /// <param name="isClientVerify">是否进行客户端验证支付</param>
        [DllImport("__Internal")]
        private static extern void __gfx_iap_init(string isDebug,string isClientVerify);

        /// <summary>
        /// 消耗购买
        /// </summary>
        /// <param name="purchaseToken">购买令牌</param>
        [DllImport("__Internal")]
        private static extern void __gfx_iap_consume(string purchaseToken);

        /// <summary>
        /// 支付系统是否准备好
        /// </summary>
        /// <returns>准备好返回true,没有则返回false</returns>
        [DllImport("__Internal")]
        private static extern string __gfx_iap_isReady();

        /// <summary>
        /// 恢复一次性购买商品的购买
        /// </summary>
        [DllImport("__Internal")]
        private static extern void __gfx_iap_restore();

        /// <summary>
        /// 发起购买（带完整参数）
        /// </summary>
        /// <param name="productId">商品ID</param>
        /// <param name="productType">商品类型，可以是 "inapp" 或 "subs"</param>
        /// <param name="offerToken">订阅优惠令牌（仅订阅商品需要）</param>
        /// <param name="obfuscatedAccountId">混淆的账户ID，用于标识购买用户的账户</param>
        /// <param name="obfuscatedProfileId">混淆的配置文件ID，用于标识购买用户的配置文件</param>
        [DllImport("__Internal")]
        private static extern void __gfx_iap_buy(string productId, string productType, string obfuscatedAccountId, string offerToken, string obfuscatedProfileId);

        /// <summary>
        /// 设置预定义商品ID列表（用于预加载缓存）
        /// 注意：此方法必须在Initialize()之前调用
        /// </summary>
        /// <param name="inAppProductIds">一次性商品ID数组</param>
        /// <param name="subsProductIds">订阅商品ID数组</param>
        [DllImport("__Internal")]
        private static extern void __gfx_iap_set_pre_defined_product_ids(string inAppProductIds, string subsProductIds);

#endif
        private const string BridgeName = "BlankInAppPurchaseBridgeLink";

        private static ApplePayStoreKit _instance;

        public static ApplePayStoreKit Instance
        {
            get
            {
                if (_instance == null)
                {
                    var go = new GameObject(BridgeName);
                    _instance = go.AddComponent<ApplePayStoreKit>();
                    DontDestroyOnLoad(go);
                }

                return _instance;
            }
        }

        private bool _isInitialized = false;

        /// <summary>
        /// 设置预定义商品ID列表（用于预加载缓存）
        /// 注意：此方法必须在Initialize()之前调用
        /// </summary>
        /// <param name="inAppProductIds">一次性商品ID数组</param>
        /// <param name="subsProductIds">订阅商品ID数组</param>
        public void SetPredefinedProductIds(List<string> inAppProductIds, List<string> subsProductIds)
        {
#if UNITY_IOS && !UNITY_EDITOR
            string inAppJson = "[]";
            try
            {
                // 将字符串数组转换为JSON格式
                inAppJson = Utility.Json.ToJson(inAppProductIds ?? new List<string>());
                Debug.Log($"设置预定义商品ID - 一次性商品: {inAppJson}");
            }
            catch (Exception e)
            {
                Debug.LogError("设置预定义商品ID失败: " + e.Message);
            }

            string subsJson = "[]";
            try
            {
                // 将字符串数组转换为JSON格式
                subsJson = Utility.Json.ToJson(subsProductIds ?? new List<string>());
                Debug.Log($"设置预定义商品ID - 订阅商品: {subsJson}");
            }
            catch (Exception e)
            {
                Debug.LogError("设置预定义商品ID失败: " + e.Message);
            }

            try
            {
                // 将字符串数组转换为JSON格式
                __gfx_iap_set_pre_defined_product_ids(inAppJson, subsJson);
            }
            catch (Exception e)
            {
                Debug.LogError("设置预定义商品ID失败: " + e.Message);
            }
#else
            Debug.Log("Apple Pay Store Kit  仅在iOS平台上可用");
#endif
        }

        /// <summary>
        /// 发起购买（带完整参数）
        /// </summary>
        /// <param name="productId">商品ID</param>
        /// <param name="productType">商品类型，可以是 "inapp" 或 "subs"</param>
        /// <param name="obfuscatedAccountId">混淆的账户ID，用于标识购买用户的账户</param>
        /// <param name="offerToken">订阅优惠令牌（仅订阅商品需要）</param>
        /// <param name="obfuscatedProfileId">混淆的配置文件ID，用于标识购买用户的配置文件</param>
        public void PurchaseWithAllParams(string productId, string productType, string obfuscatedAccountId, string offerToken, string obfuscatedProfileId)
        {
#if UNITY_IOS && !UNITY_EDITOR
            try
            {
                // 检查商品类型是否合法
                if (string.IsNullOrEmpty(productType))
                {
                    Debug.LogError("商品类型不能为空");
                    return;
                }

                if (productType != "inapp" && productType != "subs")
                {
                    Debug.LogError($"无效的商品类型: {productType}, 商品类型必须是 'inapp' 或 'subs'");
                    return;
                }

                Debug.Log($"拉起购买 - 商品ID: {productId}, 商品类型: {productType}, 混淆的账户ID: {obfuscatedAccountId}, 订阅优惠令牌: {offerToken}, 混淆的配置文件ID: {obfuscatedProfileId}");
                __gfx_iap_buy(productId, productType, obfuscatedAccountId, offerToken, obfuscatedProfileId);
                Debug.Log($"拉起购买成功");
            }
            catch (Exception e)
            {
                Debug.LogError("拉起购买失败: " + e.Message);
            }
#else
            Debug.Log("Apple Pay Store Kit  仅在iOS平台上可用");
#endif
        }

        /// <summary>
        /// 检查支付系统是否就绪
        /// </summary>
        /// <returns>如果就绪返回true，否则返回false</returns>
        public bool IsReady()
        {
#if UNITY_IOS && !UNITY_EDITOR
            try
            {
                string result = __gfx_iap_isReady();
                bool isReady = bool.Parse(result);
                Debug.Log($"检查支付系统是否就绪: {isReady}");
                return isReady;
            }
            catch (Exception e)
            {
                Debug.LogError("检查支付系统是否就绪失败: " + e.Message);
                return false;
            }
#else
            Debug.Log("Apple Pay Store Kit  仅在iOS平台上可用");
            return false;
#endif
        }

        /// <summary>
        /// 消耗购买
        /// </summary>
        /// <param name="purchaseToken">购买令牌</param>
        public void ConsumePurchase(string purchaseToken)
        {
#if UNITY_IOS && !UNITY_EDITOR
            try
            {
                __gfx_iap_consume(purchaseToken);
            }
            catch (Exception e)
            {
                Debug.LogError("消费失败: " + e.Message);
            }
#else
            Debug.Log("Apple Pay Store Kit  仅在iOS平台上可用");

#endif
        }

        /// <summary>
        /// 查询购买记录
        /// </summary>
        /// <param name="productType">产品类型，inapp/subs</param>
        public void QueryPurchases(string productType)
        {
#if UNITY_IOS && !UNITY_EDITOR
            try
            {
                __gfx_iap_query_purchases(productType);
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
#else
            Debug.Log("Apple Pay Store Kit  仅在iOS平台上可用");
#endif
        }

        /// <summary>
        /// 初始化
        /// </summary>
        /// <param name="isDebug">是否是沙盒模式</param>
        /// <param name="isClientVerify"></param>
        public void Initialize(bool isDebug, bool isClientVerify)
        {
#if UNITY_IOS && !UNITY_EDITOR
            try
            {
                if (isDebug)
                {
                    Debug.Log("Apple Pay Store Kit 初始化 - 沙盒模式");
                    __gfx_iap_init(true.ToString(), isClientVerify.ToString());
                }
                else
                {
                    Debug.Log("Apple Pay Store Kit 初始化 - 正式模式");
                    __gfx_iap_init(false.ToString(), isClientVerify.ToString());
                }
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }

#else
            Debug.Log("Apple Pay Store Kit  仅在iOS平台上可用");
#endif
        }
    }
}