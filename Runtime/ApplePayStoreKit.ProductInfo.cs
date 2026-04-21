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
using UnityEngine.Scripting;

namespace GameFrameX.Payment.Apple.Runtime
{
    /// <summary>
    /// iOS SKProduct 商品信息类
    /// 对应iOS StoreKit框架中的SKProduct对象
    /// </summary>
    [Serializable]
    [Preserve]
    public sealed class SKProductInfo
    {
        /// <summary>
        /// 产品标识符
        /// 在App Store Connect中配置的唯一商品ID
        /// </summary>
        [Preserve]
        public string ProductIdentifier { get; set; }

        /// <summary>
        /// 本地化标题
        /// 在App Store Connect中配置的商品显示名称（根据用户设备语言显示）
        /// </summary>
        [Preserve]
        public string LocalizedTitle { get; set; }

        /// <summary>
        /// 本地化描述
        /// 在App Store Connect中配置的商品详细描述（根据用户设备语言显示）
        /// </summary>
        [Preserve]
        public string LocalizedDescription { get; set; }

        /// <summary>
        /// 商品价格
        /// 以NSDecimalNumber形式表示的价格，需要结合货币信息使用
        /// </summary>
        [Preserve]
        public decimal Price { get; set; }

        /// <summary>
        /// 货币代码
        /// ISO 4217标准的三字母货币代码，如"USD"、"CNY"等
        /// </summary>
        [Preserve]
        public string CurrencyCode { get; set; }

        /// <summary>
        /// 货币符号
        /// 本地化的货币符号，如"$"、"¥"等
        /// </summary>
        [Preserve]
        public string CurrencySymbol { get; set; }

        /// <summary>
        /// 地区标识符
        /// 表示价格所属的地区和语言，如"en_US"、"zh_CN"等
        /// </summary>
        [Preserve]
        public string LocaleIdentifier { get; set; }

        /// <summary>
        /// 订阅周期单位数
        /// 订阅商品的周期数量，如1表示1个月、3表示3个月等
        /// 仅适用于iOS 11.2+的订阅商品
        /// </summary>
        [Preserve]
        public int? SubscriptionPeriodNumberOfUnits { get; set; }

        /// <summary>
        /// 订阅周期单位类型
        /// 订阅商品的周期单位：0=天，1=周，2=月，3=年
        /// 仅适用于iOS 11.2+的订阅商品
        /// </summary>
        [Preserve]
        public int? SubscriptionPeriodUnit { get; set; }

        /// <summary>
        /// 介绍价格信息
        /// 订阅商品的试用期或介绍期价格信息
        /// 仅适用于iOS 11.2+的订阅商品
        /// </summary>
        [Preserve]
        public SKProductIntroductoryPrice IntroductoryPrice { get; set; }

        /// <summary>
        /// 折扣信息列表
        /// 商品的促销折扣信息数组
        /// 仅适用于iOS 12.0+
        /// </summary>
        [Preserve]
        public List<SKProductDiscount> Discounts { get; set; }

        /// <summary>
        /// 订阅组标识符
        /// 标识订阅商品所属的订阅组，同组内的订阅商品互斥
        /// 仅适用于iOS 12.2+的订阅商品
        /// </summary>
        [Preserve]
        public string SubscriptionGroupIdentifier { get; set; }
    }

    /// <summary>
    /// iOS SKProductDiscount 商品折扣信息类
    /// 对应iOS StoreKit框架中的SKProductDiscount对象
    /// </summary>
    [Preserve]
    [Serializable]
    public sealed class SKProductDiscount
    {
        /// <summary>
        /// 折扣价格
        /// 促销活动的折扣价格
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
        /// 折扣标识符
        /// 在App Store Connect中配置的折扣活动标识符
        /// </summary>
        [Preserve]
        public string Identifier { get; set; }

        /// <summary>
        /// 支付模式
        /// 0=免费试用，1=预付费，2=按期付费
        /// </summary>
        [Preserve]
        public int PaymentMode { get; set; }

        /// <summary>
        /// 周期数量
        /// 折扣价格持续的周期数
        /// </summary>
        [Preserve]
        public int NumberOfPeriods { get; set; }

        /// <summary>
        /// 订阅周期单位数
        /// 折扣周期的单位数量
        /// </summary>
        [Preserve]
        public int? SubscriptionPeriodNumberOfUnits { get; set; }

        /// <summary>
        /// 订阅周期单位类型
        /// 折扣周期的单位类型：0=天，1=周，2=月，3=年
        /// </summary>
        [Preserve]
        public int? SubscriptionPeriodUnit { get; set; }
    }

    /// <summary>
    /// 订阅周期单位枚举
    /// 对应iOS StoreKit中的SKProduct.PeriodUnit
    /// </summary>
    [Preserve]
    public enum SKSubscriptionPeriodUnit
    {
        /// <summary>
        /// 天
        /// </summary>
        [Preserve] Day = 0,

        /// <summary>
        /// 周
        /// </summary>
        [Preserve] Week = 1,

        /// <summary>
        /// 月
        /// </summary>
        [Preserve] Month = 2,

        /// <summary>
        /// 年
        /// </summary>
        [Preserve] Year = 3
    }

    /// <summary>
    /// 支付模式枚举
    /// 对应iOS StoreKit中的SKProductDiscount.PaymentMode
    /// </summary>
    [Preserve]
    public enum SKPaymentMode
    {
        /// <summary>
        /// 免费试用
        /// </summary>
        [Preserve] FreeTrial = 0,

        /// <summary>
        /// 预付费
        /// </summary>
        [Preserve] PayAsYouGo = 1,

        /// <summary>
        /// 按期付费
        /// </summary>
        [Preserve] PayUpFront = 2
    }
}