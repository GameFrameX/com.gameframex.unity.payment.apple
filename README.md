# Apple App Store 应用内支付集成指南

本文档提供了如何在 Unity 项目中集成 Apple App Store 应用内支付功能的详细说明。

## 目录

1. [概述](#概述)
2. [前提条件](#前提条件)
3. [集成步骤](#集成步骤)
4. [API 说明](#api-说明)
5. [使用示例](#使用示例)
6. [常见问题](#常见问题)

## 概述

本插件提供了一套简单易用的 API，用于在 Unity 应用中集成 Apple App Store 应用内支付功能。它封装了 StoreKit 的复杂性，提供了一个统一的接口，使开发者能够轻松实现以下功能：

- 初始化 Apple App Store Billing
- 查询商品详情
- 购买商品（一次性商品和订阅）
- 消耗购买（消耗型商品）
- 查询购买历史

## 前提条件

1. Unity 2019.4 或更高版本
2. iOS 构建支持
3. Apple 开发者账号
4. 在 App Store Connect 中配置好的应用内商品

## 集成步骤

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

## API 说明

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

## 使用示例

请参考项目中的示例代码，其中包含了完整的使用示例，包括：

- 初始化 Apple App Store Billing
- 查询商品详情
- 购买商品
- 消耗购买
- 查询购买历史

## 常见问题

### 1. 如何区分消耗型商品和非消耗型商品？

在 App Store Connect 中，您可以将商品配置为「消耗型」或「非消耗型」。在代码中，您可以通过商品 ID 的前缀或其他方式来区分它们。

### 2. 购买成功后如何处理？

购买成功后，您应该：

- 对于消耗型商品：调用 `ConsumePurchase` 方法消耗购买，然后给予用户相应的游戏内物品。
- 对于非消耗型商品：确认购买（插件会自动处理），然后解锁相应的功能。
- 对于订阅商品：确认购买（插件会自动处理），然后授予用户订阅权益。

### 3. 如何处理未完成的购买？

插件在初始化时会自动查询未处理的购买，并触发相应的事件。您应该在 `OnPurchaseCompleted` 事件中处理这些未完成的购买。

### 4. 如何测试应用内购买？

Apple 提供了沙盒环境，您可以创建测试账号，并使用测试卡进行购买测试，而不会产生实际费用。详情请参考 [Apple App Store 测试应用内购买](https://developer.apple.com/documentation/storekit/testing_in-app_purchases)。

---

如有任何问题或建议，请联系开发者。
