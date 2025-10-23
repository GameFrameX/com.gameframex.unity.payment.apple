// GameFrameX 组织下的以及组织衍生的项目的版权、商标、专利和其他相关权利均受相应法律法规的保护。使用本项目应遵守相关法律法规和许可证的要求。
// 
// 本项目主要遵循 MIT 许可证和 Apache 许可证（版本 2.0）进行分发和使用。许可证位于源代码树根目录中的 LICENSE 文件。
// 
// 不得利用本项目从事危害国家安全、扰乱社会秩序、侵犯他人合法权益等法律法规禁止的活动！任何基于本项目二次开发而产生的一切法律纠纷和责任，我们不承担任何责任！

using System;
using UnityEngine.Scripting;

namespace GameFrameX.Payment.Apple.Runtime
{
    /// <summary>
    /// iOS SKProductIntroductoryPrice 介绍价格信息类
    /// 对应iOS StoreKit框架中的SKProductDiscount对象（用于介绍价格）
    /// </summary>
    [Serializable]
    [Preserve]
    public sealed class SKProductIntroductoryPrice
    {
        /// <summary>
        /// 介绍价格
        /// 试用期或介绍期的价格
        /// </summary>
        [Preserve]
        public decimal Price { get; set; }

        /// <summary>
        /// 货币代码
        /// ISO 4217标准的三字母货币代码
        /// </summary>
        [Preserve]
        public string CurrencyCode { get; set; }

        /// <summary>
        /// 支付模式
        /// 0=免费试用，1=预付费，2=按期付费
        /// </summary>
        [Preserve]
        public int PaymentMode { get; set; }

        /// <summary>
        /// 周期数量
        /// 介绍价格持续的周期数
        /// </summary>
        [Preserve]
        public int NumberOfPeriods { get; set; }

        /// <summary>
        /// 订阅周期单位数
        /// 介绍价格周期的单位数量
        /// </summary>
        [Preserve]
        public int? SubscriptionPeriodNumberOfUnits { get; set; }

        /// <summary>
        /// 订阅周期单位类型
        /// 介绍价格周期的单位类型：0=天，1=周，2=月，3=年
        /// </summary>
        [Preserve]
        public int? SubscriptionPeriodUnit { get; set; }
    }
}