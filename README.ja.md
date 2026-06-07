<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# Game Frame X Payment Apple

[![License](https://img.shields.io/github/license/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/blob/main/LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/releases)
[![Documentation](https://img.shields.io/badge/Documentation-docs-blue)](https://gameframex.doc.alianblank.com)

インディゲーム開発者向けオールインワンソリューション · インディ開発者の夢を支援

<br />

[ドキュメント](https://gameframex.doc.alianblank.com) · [クイックスタート](#クイックスタート) · [QQグループ](https://qm.qq.com/q/5U9Fvebw)

<br />

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | **日本語** | [한국어](README.ko.md)

</div>
## プロジェクト概要

このプラグインは、Unity アプリケーションに Apple App Store のアプリ内課金機能を統合するためのシンプルで使いやすい API を提供します。StoreKit の複雑さをカプセル化し、統一されたインターフェースを提供することで、開発者が以下の機能を簡単に実装できるようにします：

- Apple App Store Billing の初期化
- 商品詳細の照会
- 商品の購入（一回限り商品とサブスクリプション）
- 購入の消費（消費型商品）
- 購入履歴の照会

## クイックスタート

### 1. プラグインのインポート

`GameFrameX.Payment.Apple` プラグインを Unity プロジェクトにインポートします。

### 2. Unity での使用

ゲームシーンに `ApplePaymentManager` コンポーネントを追加するか、コードから動的に作成します：

```csharp
// ApplePaymentManager インスタンスを取得
var billingManager = GameFrameX.Payment.PaymentModule.GetPaymentManager<ApplePaymentManager>();

// イベントリスナーを登録
billingManager.OnInitialized += OnInitialized;
billingManager.OnProductsQueried += OnProductsQueried;
billingManager.OnPurchaseCompleted += OnPurchaseCompleted;

// 初期化
billingManager.Init();
```

## 使用例

### 初期化

```csharp
// Apple App Store Billing を初期化
billingManager.Init(bool isDebug = false, bool isClientVerify = false);
```

### 商品の照会

```csharp
// 一回限り商品を照会
billingManager.QueryPurchases("inapp");

// サブスクリプション商品を照会
billingManager.QueryPurchases("subs");
```

### 商品の購入

```csharp
// 一回限り商品を購入
billingManager.BuyInApp("product_id", "order_id");

// サブスクリプション商品を購入
billingManager.BuySubs("subscription_id", "order_id");

// オファー付きサブスクリプション商品を購入
billingManager.BuySubs("subscription_id", "order_id", "offer_token");
```

### 購入の消費

```csharp
// 購入を消費（消費型商品のみ）
billingManager.ConsumePurchase("purchase_token");
```

### 購入履歴の照会

```csharp
// 一回限り商品の購入履歴を照会
billingManager.QueryPurchases("inapp");

// サブスクリプション商品の購入履歴を照会
billingManager.QueryPurchases("subs");
```

## プラットフォーム対応

| プラットフォーム | 対応 |
|------------------|------|
| iOS              | はい |

## 変更履歴

詳細は [CHANGELOG.md](CHANGELOG.md) をご覧ください。

## ライセンス

詳しくは [LICENSE.md](LICENSE.md) をご参照ください。
