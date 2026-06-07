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

### Installation

Choose one of the following methods:

1. Edit your Unity project's `Packages/manifest.json` and add the `scopedRegistries` section:
   ```json
   {
     "scopedRegistries": [
       {
         "name": "GameFrameX",
         "url": "https://gameframex.upm.alianblank.uk",
         "scopes": [
           "com.gameframex"
         ]
       }
     ],
     "dependencies": {
       "com.gameframex.unity.payment.apple": "1.0.1"
     }
   }
   ```

   `scopes` controls which packages are resolved through this registry. Only packages whose names start with `com.gameframex` will be fetched from it.

2. Add to `manifest.json` dependencies:
   ```json
   {
      "com.gameframex.unity.payment.apple": "https://github.com/gameframex/com.gameframex.unity.payment.apple.git"
   }
   ```
3. Use **Package Manager** in Unity with **Git URL**: `https://github.com/gameframex/com.gameframex.unity.payment.apple.git`
4. Clone the repository into your Unity project's `Packages` directory. It will be loaded automatically.
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


## Dependencies

| Package | Description |
|---------|-------------|
| `com.gameframex.unity` | 1.1.1 |

## Documentation & Resources

- [Documentation](https://gameframex.doc.alianblank.com)

## Community & Support

- QQ Group: 467608841 / 233840761
## License

See [LICENSE.md](LICENSE.md) for license information.
