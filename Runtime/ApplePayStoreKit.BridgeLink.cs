// ==========================================================================================
//   GameFrameX 组织及其衍生项目的版权、商标、专利及其他相关权利
//   GameFrameX organization and its derivative projects' copyrights, trademarks, patents, and related rights
//   均受中华人民共和国及相关国际法律法规保护。
//   are protected by the laws of the People's Republic of China and relevant international regulations.
//   使用本项目须严格遵守相应法律法规及开源许可证之规定。
//   Usage of this project must strictly comply with applicable laws, regulations, and open-source licenses.
//   本项目采用 MIT 许可证与 Apache License 2.0 双许可证分发，
//   This project is dual-licensed under the MIT License and Apache License 2.0,
//   完整许可证文本请参见源代码根目录下的 LICENSE 文件。
//   please refer to the LICENSE file in the root directory of the source code for the full license text.
//   禁止利用本项目实施任何危害国家安全、破坏社会秩序、
//   It is prohibited to use this project to engage in any activities that endanger national security, disrupt social order,
//   侵犯他人合法权益等法律法规所禁止的行为！
//   or infringe upon the legitimate rights and interests of others, as prohibited by laws and regulations!
//   因基于本项目二次开发所产生的一切法律纠纷与责任，
//   Any legal disputes and liabilities arising from secondary development based on this project
//   本项目组织与贡献者概不承担。
//   shall be borne solely by the developer; the project organization and contributors assume no responsibility.
//   GitHub 仓库：https://github.com/GameFrameX
//   GitHub Repository: https://github.com/GameFrameX
//   Gitee  仓库：https://gitee.com/GameFrameX
//   Gitee Repository:  https://gitee.com/GameFrameX
//   CNB  仓库：https://cnb.cool/GameFrameX
//   CNB Repository:  https://cnb.cool/GameFrameX
//   官方文档：https://gameframex.doc.alianblank.com/
//   Official Documentation: https://gameframex.doc.alianblank.com/
//  ==========================================================================================

using System;
using System.Collections.Generic;
using GameFrameX.Runtime;
using UnityEngine;
using UnityEngine.Scripting;

namespace GameFrameX.Payment.Apple.Runtime
{
    public partial class ApplePayStoreKit
    {
        #region 消息代码

        // 初始化相关
        [Preserve] private const int InitSuccess = 1000;
        [Preserve] private const int InitFail = 1001;

        // 查询商品相关
        [Preserve] private const int QueryProductsSuccess = 2000;
        [Preserve] private const int QueryProductsFail = 2001;

        // 购买相关
        [Preserve] private const int PurchaseSuccess = 3000;
        [Preserve] private const int PurchaseFail = 3001;

        [Preserve] private const int PurchaseCancel = 3002;

        // 购买检查
        [Preserve] private const int PurchaseCheckSuccess = 3100;
        [Preserve] private const int PurchaseCheckFail = 3101;

        // 消耗相关
        [Preserve] private const int ConsumeSuccess = 4000;
        [Preserve] private const int ConsumeFail = 4001;

        // 查询购买历史相关
        [Preserve] private const int QueryPurchasesSuccess = 5000;
        [Preserve] private const int QueryPurchasesFail = 5001;

        #endregion

        #region 事件定义

        // 初始化事件
        [Preserve] public event Action<bool, string> OnInitialized;

        // 查询商品事件
        [Preserve] public event Action<bool, List<SKProductInfo>> OnProductsQueried;

        // 购买事件
        [Preserve] public event Action<bool, PurchaseInfo> OnPurchaseCompleted;
        [Preserve] public event Action OnPurchaseCancelled;

        // 消耗事件
        [Preserve] public event Action<bool, string> OnPurchaseConsumed;
        // 购买验证
        [Preserve] public event Action<bool, string> OnPurchaseCheck;

        // 查询购买历史事件
        [Preserve] public event Action<bool, List<PurchaseInfo>> OnPurchasesQueried;

        #endregion


        #region 消息处理

        /// <summary>
        /// 接收来自Android的消息
        /// 此方法由Android端通过UnitySendMessage调用
        /// </summary>
        /// <param name="message">消息内容，格式为 "消息代码|消息内容"</param>
        [Preserve]
        public void OnMessage(string message)
        {
            Debug.Log("收到来自 iOS 的消息: " + message);

            try
            {
                string[] parts = message.Split(new char[] { '|' }, 2);
                if (parts.Length < 2)
                {
                    Debug.LogError("无效的消息格式: " + message);
                    return;
                }

                int messageCode = int.Parse(parts[0]);
                string messageContent = parts[1];

                ProcessMessage(messageCode, messageContent);
            }
            catch (Exception e)
            {
                Debug.LogError("处理消息时出错: " + e.Message);
            }
        }

        /// <summary>
        /// 处理消息
        /// </summary>
        /// <param name="messageCode">消息代码</param>
        /// <param name="messageContent">消息内容</param>
        private void ProcessMessage(int messageCode, string messageContent)
        {
            switch (messageCode)
            {
                // 初始化相关
                case InitSuccess:
                    _isInitialized = true;
                    Debug.Log("Google Play Billing 初始化成功: " + messageContent);
                    OnInitialized?.Invoke(true, messageContent);
                    break;

                case InitFail:
                    _isInitialized = false;
                    Debug.LogError("Google Play Billing 初始化失败: " + messageContent);
                    OnInitialized?.Invoke(false, messageContent);
                    break;

                // 查询商品相关
                case QueryProductsSuccess:
                    Debug.Log("查询商品成功: " + messageContent);
                    var products = ParseProductsJson(messageContent);
                    OnProductsQueried?.Invoke(true, products);
                    break;

                case QueryProductsFail:
                    Debug.LogError("查询商品失败: " + messageContent);
                    OnProductsQueried?.Invoke(false, null);
                    break;

                // 购买相关
                case PurchaseSuccess:
                    Debug.Log("购买成功: " + messageContent);
                    PurchaseInfo purchaseInfo = ParsePurchaseJson(messageContent);
                    OnPurchaseCompleted?.Invoke(true, purchaseInfo);
                    break;

                case PurchaseFail:
                    Debug.LogError("购买失败: " + messageContent);
                    OnPurchaseCompleted?.Invoke(false, null);
                    break;

                case PurchaseCancel:
                    Debug.Log("购买取消: " + messageContent);
                    OnPurchaseCancelled?.Invoke();
                    break;

                // 消耗相关
                case ConsumeSuccess:
                    Debug.Log("消耗成功: " + messageContent);
                    OnPurchaseConsumed?.Invoke(true, messageContent);
                    break;

                case ConsumeFail:
                    Debug.LogError("消耗失败: " + messageContent);
                    OnPurchaseConsumed?.Invoke(false, messageContent);
                    break;

                // 购买验证
                case PurchaseCheckSuccess:
                    Debug.Log("验证成功: " + messageContent);
                    OnPurchaseCheck?.Invoke(true, messageContent);
                    break;

                case PurchaseCheckFail:
                    Debug.LogError("验证失败: " + messageContent);
                    OnPurchaseCheck?.Invoke(false, messageContent);
                    break;

                // 查询购买历史相关
                case QueryPurchasesSuccess:
                    Debug.Log("查询购买历史成功: " + messageContent);
                    List<PurchaseInfo> purchases = ParsePurchasesJson(messageContent);
                    OnPurchasesQueried?.Invoke(true, purchases);
                    break;

                case QueryPurchasesFail:
                    Debug.LogError("查询购买历史失败: " + messageContent);
                    OnPurchasesQueried?.Invoke(false, null);
                    break;

                default:
                    Debug.LogWarning("未知的消息代码: " + messageCode);
                    break;
            }
        }

        #endregion

        #region JSON解析

        /// <summary>
        /// 解析商品JSON
        /// </summary>
        private List<SKProductInfo> ParseProductsJson(string json)
        {
            var products = new List<SKProductInfo>();

            try
            {
                if (string.IsNullOrEmpty(json) || json == "[]")
                {
                    return products;
                }

                return Utility.Json.ToObject<List<SKProductInfo>>(json);
            }
            catch (Exception e)
            {
                Debug.LogError("解析商品JSON失败: " + e.Message);
            }

            return products;
        }

        /// <summary>
        /// 解析单个购买JSON
        /// </summary>
        private PurchaseInfo ParsePurchaseJson(string json)
        {
            try
            {
                if (string.IsNullOrEmpty(json))
                {
                    return null;
                }

                return Utility.Json.ToObject<PurchaseInfo>(json);
            }
            catch (Exception e)
            {
                Debug.LogError("解析购买JSON失败: " + e.Message);
                return null;
            }
        }

        /// <summary>
        /// 解析购买历史JSON
        /// </summary>
        private List<PurchaseInfo> ParsePurchasesJson(string json)
        {
            List<PurchaseInfo> purchases = new List<PurchaseInfo>();

            try
            {
                if (string.IsNullOrEmpty(json) || json == "[]")
                {
                    return purchases;
                }

                purchases = Utility.Json.ToObject<List<PurchaseInfo>>(json);
            }
            catch (Exception e)
            {
                Debug.LogError("解析购买历史JSON失败: " + e.Message);
            }

            return purchases;
        }

        #endregion
    }
}