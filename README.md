<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# Game Frame X Payment Apple

[![License](https://img.shields.io/github/license/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/blob/main/LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/releases)
[![Unity Version](https://img.shields.io/badge/Unity-2019.4-black?logo=unity)](https://unity.com/)
[![Documentation](https://img.shields.io/badge/Documentation-docs-blue)](https://gameframex.doc.alianblank.com)

All-in-One Solution for Indie Game Development · Empowering Indie Developers' Dreams

<br />

[Documentation](https://gameframex.doc.alianblank.com) · [Quick Start](#quick-start) · QQ Group: 467608841 / 233840761

<br />

**English** | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

</div>

## Project Overview

This plugin provides a simple and easy-to-use API for integrating Apple App Store in-app purchase functionality into Unity applications. It encapsulates the complexity of StoreKit and provides a unified interface, enabling developers to easily implement:

- Initialize Apple App Store Billing
- Query product details
- Purchase products (one-time products and subscriptions)
- Consume purchases (consumable products)
- Query purchase history

## Quick Start

### 1. Import Plugin

Import the `GameFrameX.Payment.Apple` plugin into your Unity project.

### 2. Usage

Add the `ApplePaymentManager` component to your game scene, or create it dynamically via code:

```csharp
// Get ApplePaymentManager instance
var billingManager = GameFrameX.Payment.PaymentModule.GetPaymentManager<ApplePaymentManager>();

// Register event listeners
billingManager.OnInitialized += OnInitialized;
billingManager.OnProductsQueried += OnProductsQueried;
billingManager.OnPurchaseCompleted += OnPurchaseCompleted;

// Initialize
billingManager.Init();
```

## Usage Examples

### Initialize

```csharp
// Initialize Apple App Store Billing
billingManager.Init(bool isDebug = false, bool isClientVerify = false);
```

### Query Products

```csharp
// Query one-time products
billingManager.QueryPurchases("inapp");

// Query subscription products
billingManager.QueryPurchases("subs");
```

### Purchase Products

```csharp
// Purchase a one-time product
billingManager.BuyInApp("product_id", "order_id");

// Purchase a subscription product
billingManager.BuySubs("subscription_id", "order_id");

// Purchase a subscription product with an offer
billingManager.BuySubs("subscription_id", "order_id", "offer_token");
```

### Consume Purchase

```csharp
// Consume purchase (only for consumable products)
billingManager.ConsumePurchase("purchase_token");
```

### Query Purchase History

```csharp
// Query purchase history for one-time products
billingManager.QueryPurchases("inapp");

// Query purchase history for subscription products
billingManager.QueryPurchases("subs");
```

## Platform Support

| Platform | Supported |
|----------|-----------|
| iOS      | Yes       |

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details.

## License

See [LICENSE.md](LICENSE.md) for license information.
