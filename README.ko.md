<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# Game Frame X Payment Apple

[![License](https://img.shields.io/github/license/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/blob/main/LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/com.gameframex.unity.payment.apple)](https://github.com/GameFrameX/com.gameframex.unity.payment.apple/releases)
[![Unity Version](https://img.shields.io/badge/Unity-2019.4-black?logo=unity)](https://unity.com/)
[![Documentation](https://img.shields.io/badge/Documentation-docs-blue)](https://gameframex.doc.alianblank.com)

인디 게임 개발자를 위한 올인원 솔루션 · 인디 개발자의 꿈을 실현

<br />

[문서](https://gameframex.doc.alianblank.com) · [빠른 시작](#빠른-시작) · QQ 그룹: 467608841 / 233840761

<br />

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | **한국어**

</div>

## 프로젝트 개요

이 플러그인은 Unity 애플리케이션에 Apple App Store 인앱 결제 기능을 통합하기 위한 간단하고 사용하기 쉬운 API를 제공합니다. StoreKit의 복잡성을 캡슐화하고 통합된 인터페이스를 제공하여 개발자가 다음 기능을 쉽게 구현할 수 있도록 합니다:

- Apple App Store Billing 초기화
- 상품 상세 조회
- 상품 구매 (일회성 상품 및 구독)
- 구매 소비 (소비성 상품)
- 구매 내역 조회

## 빠른 시작

### 설치

Unity 프로젝트의 `Packages/manifest.json`을 편집하여 `scopedRegistries` 섹션을 추가하세요:

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
  ]
}
```

`scopes`는 이 레지스트리를 통해 어떤 패키지를 해석할지 제어합니다. `com.gameframex`로 시작하는 패키지만 이 레지스트리에서 가져옵니다.

Then add the package to `dependencies`:

```json
{
  "dependencies": {
    "com.gameframex.unity.payment.apple": "1.0.1"
  }
}
```


## 사용 예시

### 초기화

```csharp
// Apple App Store Billing 초기화
billingManager.Init(bool isDebug = false, bool isClientVerify = false);
```

### 상품 조회

```csharp
// 일회성 상품 조회
billingManager.QueryPurchases("inapp");

// 구독 상품 조회
billingManager.QueryPurchases("subs");
```

### 상품 구매

```csharp
// 일회성 상품 구매
billingManager.BuyInApp("product_id", "order_id");

// 구독 상품 구매
billingManager.BuySubs("subscription_id", "order_id");

// 할인이 포함된 구독 상품 구매
billingManager.BuySubs("subscription_id", "order_id", "offer_token");
```

### 구매 소비

```csharp
// 구매 소비 (소비성 상품에만 해당)
billingManager.ConsumePurchase("purchase_token");
```

### 구매 내역 조회

```csharp
// 일회성 상품 구매 내역 조회
billingManager.QueryPurchases("inapp");

// 구독 상품 구매 내역 조회
billingManager.QueryPurchases("subs");
```

## 플랫폼 지원

| 플랫폼 | 지원 |
|--------|------|
| iOS    | 예   |

## 변경 로그

자세한 내용은 [CHANGELOG.md](CHANGELOG.md)를 참조하세요.


## 의존성

| 패키지 | 설명 |
|--------|------|
| `com.gameframex.unity` | 1.1.1 |

## 문서 및 자료

- [문서](https://gameframex.doc.alianblank.com)

## 커뮤니티 및 지원

- QQ 그룹: 467608841 / 233840761
## 라이선스

자세한 내용은 [LICENSE.md](LICENSE.md) 파일을 참조하세요.
