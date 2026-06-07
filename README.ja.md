<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# Game Frame X Payment Apple

[![License](https://img.shields.io/github/license/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/blob/main/LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/releases)
[![Unity Version](https://img.shields.io/badge/Unity-2019.4-black?logo=unity)](https://unity.com/)
[![Documentation](https://img.shields.io/badge/Documentation-docs-blue)](https://gameframex.doc.alianblank.com)

インディゲーム開発者向けオールインワンソリューション · インディ開発者の夢を支援

<br />

[ドキュメント](https://gameframex.doc.alianblank.com) · [クイックスタート](#クイックスタート) · QQグループ: 467608841 / 233840761

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

### インストール

以下のいずれかの方法を選択してください：

1. Unity プロジェクトの `Packages/manifest.json` を編集し、`scopedRegistries` セクションを追加してください：
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

   `scopes` は、どのパッケージをこのレジストリから解決するかを制御します。`com.gameframex` で始まるパッケージのみがこのレジストリから取得されます。

2. `manifest.json` の `dependencies` に直接追加：
   ```json
   {
      "com.gameframex.unity.payment.apple": "https://github.com/gameframex/com.gameframex.unity.payment.apple.git"
   }
   ```
3. Unity の **Package Manager** で **Git URL** を使用して追加：`https://github.com/gameframex/com.gameframex.unity.payment.apple.git`
4. リポジトリを Unity プロジェクトの `Packages` ディレクトリにクローンしてください。自動的に読み込まれます。
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


## 依存関係

| パッケージ | 説明 |
|----------|------|
| `com.gameframex.unity` | 1.1.1 |

## ドキュメントとリソース

- [ドキュメント](https://gameframex.doc.alianblank.com)

## コミュニティとサポート

- QQグループ: 467608841 / 233840761
## ライセンス

詳しくは [LICENSE.md](LICENSE.md) をご参照ください。
