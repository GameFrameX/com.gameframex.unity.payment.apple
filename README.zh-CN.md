<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# Game Frame X Payment Apple

[![License](https://img.shields.io/github/license/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/blob/main/LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/releases)
[![Documentation](https://img.shields.io/badge/Documentation-docs-blue)](https://gameframex.doc.alianblank.com)

独立游戏前后端一体化解决方案 · 独立游戏开发者的圆梦大使

<br />

[文档](https://gameframex.doc.alianblank.com) · [快速开始](#快速开始) · [QQ群](https://qm.qq.com/q/5U9Fvebw)

<br />

[English](README.md) | **简体中文** | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

</div>

## 项目简介

本插件提供了一套简单易用的 API，用于在 Unity 应用中集成 Apple App Store 应用内支付功能。它封装了 StoreKit 的复杂性，提供了一个统一的接口，使开发者能够轻松实现以下功能：

- 初始化 Apple App Store Billing
- 查询商品详情
- 购买商品（一次性商品和订阅）
- 消耗购买（消耗型商品）
- 查询购买历史

## 快速开始

### 1. 导入插件

将 `GameFrameX.Payment.Apple` 插件导入到您的 Unity 项目中。

### 2. 在 Unity 中使用

在您的游戏场景中添加 `ApplePaymentManager` 组件，或者通过代码动态创建：

```csharp
// 获取 ApplePaymentManager 实例
var billingManager = GameFrameX.Payment.PaymentModule.GetPaymentManager<ApplePaymentManager>();

// 注册事件监听
billingManager.OnInitialized += OnInitialized;
billingManager.OnProductsQueried += OnProductsQueried;
billingManager.OnPurchaseCompleted += OnPurchaseCompleted;

// 初始化
billingManager.Init();
```

## 使用示例

### 初始化

```csharp
// 初始化 Apple App Store Billing
billingManager.Init(bool isDebug = false, bool isClientVerify = false);
```

### 查询商品

```csharp
// 查询一次性商品
billingManager.QueryPurchases("inapp");

// 查询订阅商品
billingManager.QueryPurchases("subs");
```

### 购买商品

```csharp
// 购买一次性商品
billingManager.BuyInApp("product_id", "order_id");

// 购买订阅商品
billingManager.BuySubs("subscription_id", "order_id");

// 购买带优惠的订阅商品
billingManager.BuySubs("subscription_id", "order_id", "offer_token");
```

### 消耗购买

```csharp
// 消耗购买（仅适用于消耗型商品）
billingManager.ConsumePurchase("purchase_token");
```

### 查询购买历史

```csharp
// 查询一次性商品的购买历史
billingManager.QueryPurchases("inapp");

// 查询订阅商品的购买历史
billingManager.QueryPurchases("subs");
```

## 平台支持

| 平台 | 支持 |
|------|------|
| iOS  | 是   |

## 更新日志

详见 [CHANGELOG.md](CHANGELOG.md)。

## 开源协议

详见 [LICENSE.md](LICENSE.md) 文件。
