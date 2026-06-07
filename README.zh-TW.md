<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# Game Frame X Payment Apple

[![License](https://img.shields.io/github/license/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/blob/main/LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/releases)
[![Documentation](https://img.shields.io/badge/Documentation-docs-blue)](https://gameframex.doc.alianblank.com)

獨立遊戲前後端一體化解決方案 · 獨立遊戲開發者的圓夢大使

<br />

[文檔](https://gameframex.doc.alianblank.com) · [快速開始](#快速開始) · QQ群: 467608841 / 233840761

<br />

[English](README.md) | [简体中文](README.zh-CN.md) | **繁體中文** | [日本語](README.ja.md) | [한국어](README.ko.md)

</div>
## 項目簡介

本插件提供了一套簡單易用的 API，用於在 Unity 應用中整合 Apple App Store 應用內支付功能。它封裝了 StoreKit 的複雜性，提供了統一的介面，使開發者能夠輕鬆實現以下功能：

- 初始化 Apple App Store Billing
- 查詢商品詳情
- 購買商品（一次性商品和訂閱）
- 消耗購買（消耗型商品）
- 查詢購買歷史

## 快速開始

### 1. 匯入插件

將 `GameFrameX.Payment.Apple` 插件匯入到您的 Unity 專案中。

### 2. 在 Unity 中使用

在您的遊戲場景中新增 `ApplePaymentManager` 元件，或者透過程式碼動態建立：

```csharp
// 取得 ApplePaymentManager 實例
var billingManager = GameFrameX.Payment.PaymentModule.GetPaymentManager<ApplePaymentManager>();

// 註冊事件監聽
billingManager.OnInitialized += OnInitialized;
billingManager.OnProductsQueried += OnProductsQueried;
billingManager.OnPurchaseCompleted += OnPurchaseCompleted;

// 初始化
billingManager.Init();
```

## 使用範例

### 初始化

```csharp
// 初始化 Apple App Store Billing
billingManager.Init(bool isDebug = false, bool isClientVerify = false);
```

### 查詢商品

```csharp
// 查詢一次性商品
billingManager.QueryPurchases("inapp");

// 查詢訂閱商品
billingManager.QueryPurchases("subs");
```

### 購買商品

```csharp
// 購買一次性商品
billingManager.BuyInApp("product_id", "order_id");

// 購買訂閱商品
billingManager.BuySubs("subscription_id", "order_id");

// 購買帶優惠的訂閱商品
billingManager.BuySubs("subscription_id", "order_id", "offer_token");
```

### 消耗購買

```csharp
// 消耗購買（僅適用於消耗型商品）
billingManager.ConsumePurchase("purchase_token");
```

### 查詢購買歷史

```csharp
// 查詢一次性商品的購買歷史
billingManager.QueryPurchases("inapp");

// 查詢訂閱商品的購買歷史
billingManager.QueryPurchases("subs");
```

## 平台支援

| 平台 | 支援 |
|------|------|
| iOS  | 是   |

## 更新日誌

詳見 [CHANGELOG.md](CHANGELOG.md)。

## 開源協議

詳見 [LICENSE.md](LICENSE.md) 檔案。
