import StoreKit
import Foundation

// MARK: - UnitySendMessage Bridge

@_silgen_name("UnitySendMessage")
func UnitySendMessage(_ obj: UnsafePointer<CChar>,
                      _ method: UnsafePointer<CChar>,
                      _ msg: UnsafePointer<CChar>) -> Void

// MARK: - Constants

private let kBridgeObject = "BlankInAppPurchaseBridgeLink"

// Message codes (matching SK1 GameFrameXViewController.mm)
private let kInitSuccess = 1000
private let kInitFail = 1001
private let kQueryProductsSuccess = 2000
private let kQueryProductsFail = 2001
private let kPurchaseSuccess = 3000
private let kPurchaseFail = 3001
private let kPurchaseCancel = 3002
private let kPurchaseCheckSuccess = 3100
private let kPurchaseCheckFail = 3101
private let kConsumeSuccess = 4000
private let kConsumeFail = 4001
private let kQueryPurchasesSuccess = 5000
private let kQueryPurchasesFail = 5001

// MARK: - State

private var productIds: [String] = []
private var products: [String: Product] = [:]
private var sk2IsReady = false
private var isDebug = false
private var isClientVerify = false
private var pendingTransactions: [String: Transaction] = [:]
private var updatesTask: Task<Void, Never>?

// MARK: - Thread-safe Unity Callback

private func sendToUnity(_ message: String, method: String = "OnMessage") {
    if Thread.isMainThread {
        message.withCString { msg in
            method.withCString { m in
                kBridgeObject.withCString { obj in
                    UnitySendMessage(obj, m, msg)
                }
            }
        }
    } else {
        let msgCopy = message
        let methodCopy = method
        DispatchQueue.main.async {
            msgCopy.withCString { msg in
                methodCopy.withCString { m in
                    kBridgeObject.withCString { obj in
                        UnitySendMessage(obj, m, msg)
                    }
                }
            }
        }
    }
}

private func sendMessage(_ content: String, code: Int) {
    sendToUnity("\(code)|\(content)")
}

// MARK: - UUID Conversion (matches SK1 uuidFromLongLong)

private func uuidFromAccountId(_ accountId: String) -> UUID? {
    guard let value = Int64(accountId) else { return nil }
    var bytes: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    for i in 0..<8 {
        bytes[i] = UInt8(truncatingIfNeeded: (value >> (8 * i)) & 0xFF)
    }
    return UUID(uuid: bytes)
}

// MARK: - Period/PaymentMode Conversion

private func periodUnitToInt(_ unit: Product.SubscriptionPeriod.Unit) -> Int {
    switch unit {
    case .day: return 0
    case .week: return 1
    case .month: return 2
    case .year: return 3
    @unknown default: return 0
    }
}

private func paymentModeToInt(_ mode: Product.SubscriptionOffer.PaymentMode) -> Int {
    switch mode {
    case .freeTrial: return 0
    case .payAsYouGo: return 1
    case .payUpFront: return 2
    @unknown default: return 0
    }
}

// MARK: - Locale Helpers (iOS 15 compatible)

private func getCurrencyCode(from locale: Locale) -> String {
    if #available(iOS 16, *) {
        return locale.currency?.identifier ?? ""
    } else {
        return (locale as NSLocale).object(forKey: .currencyCode) as? String ?? ""
    }
}

private func getCurrencySymbol(from locale: Locale) -> String {
    if #available(iOS 16, *) {
        return locale.currencySymbol ?? ""
    } else {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter.currencySymbol ?? ""
    }
}

private func getLocaleIdentifier(from locale: Locale) -> String {
    if #available(iOS 16, *) {
        return locale.identifier
    } else {
        return (locale as NSLocale).localeIdentifier
    }
}

// MARK: - Product Serialization

private func serializeProduct(_ product: Product) -> [String: Any] {
    var dict: [String: Any] = [:]

    let locale = product.priceFormatStyle.locale

    dict["ProductIdentifier"] = product.id
    dict["LocalizedTitle"] = product.displayName
    dict["LocalizedDescription"] = product.description
    dict["Price"] = NSDecimalNumber(decimal: product.price)
    dict["CurrencyCode"] = getCurrencyCode(from: locale)
    dict["CurrencySymbol"] = getCurrencySymbol(from: locale)
    dict["LocaleIdentifier"] = getLocaleIdentifier(from: locale)

    if let sub = product.subscription {
        let period = sub.subscriptionPeriod
        dict["SubscriptionPeriodNumberOfUnits"] = period.value
        dict["SubscriptionPeriodUnit"] = periodUnitToInt(period.unit)

        if let intro = sub.introductoryOffer {
            var introDict: [String: Any] = [:]
            introDict["Price"] = NSDecimalNumber(decimal: intro.price)
            introDict["CurrencyCode"] = getCurrencyCode(from: locale)
            introDict["PaymentMode"] = paymentModeToInt(intro.paymentMode)
            introDict["NumberOfPeriods"] = intro.periodCount
            introDict["SubscriptionPeriodNumberOfUnits"] = intro.period.value
            introDict["SubscriptionPeriodUnit"] = periodUnitToInt(intro.period.unit)
            dict["IntroductoryPrice"] = introDict
        }

        let offers = sub.promotionalOffers
        if !offers.isEmpty {
            dict["Discounts"] = offers.map { offer in
                var offerDict: [String: Any] = [:]
                offerDict["Price"] = NSDecimalNumber(decimal: offer.price)
                offerDict["CurrencyCode"] = getCurrencyCode(from: locale)
                offerDict["Identifier"] = offer.id
                offerDict["PaymentMode"] = paymentModeToInt(offer.paymentMode)
                offerDict["NumberOfPeriods"] = offer.periodCount
                offerDict["SubscriptionPeriodNumberOfUnits"] = offer.period.value
                offerDict["SubscriptionPeriodUnit"] = periodUnitToInt(offer.period.unit)
                return offerDict
            }
        }
    }

    dict["SubscriptionGroupIdentifier"] = product.subscription?.subscriptionGroupID ?? ""

    return dict
}

private func productsToJson(_ productList: [Product]) -> String {
    let array = productList.map { serializeProduct($0) }
    guard let data = try? JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted]) else {
        return "[]"
    }
    return String(data: data, encoding: .utf8) ?? "[]"
}

private func purchaseJson(productId: String, receipt: String) -> String {
    let dict: [String: Any] = ["ProductId": productId, "Receipt": receipt]
    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) else {
        return "{}"
    }
    return String(data: data, encoding: .utf8) ?? "{}"
}

// MARK: - Transaction Updates

private func startTransactionUpdates() {
    guard #available(iOS 15.0, *) else { return }
    updatesTask = Task {
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                let txId = String(transaction.id)
                pendingTransactions[txId] = transaction
                sendMessage(purchaseJson(productId: transaction.productID, receipt: txId), code: kPurchaseSuccess)
            case .unverified:
                break
            }
        }
    }
}

// MARK: - @_cdecl Entry Points

@_cdecl("__gfx_sk2_set_pre_defined_product_ids")
func __gfx_sk2_set_pre_defined_product_ids(_ inAppPtr: UnsafePointer<CChar>?,
                                             _ subPtr: UnsafePointer<CChar>?) {
    productIds = []

    if let ptr = inAppPtr {
        let str = String(cString: ptr)
        if let data = str.data(using: .utf8),
           let array = try? JSONSerialization.jsonObject(with: data) as? [String] {
            productIds.append(contentsOf: array)
        }
    }

    if let ptr = subPtr {
        let str = String(cString: ptr)
        if let data = str.data(using: .utf8),
           let array = try? JSONSerialization.jsonObject(with: data) as? [String] {
            productIds.append(contentsOf: array)
        }
    }
}

@_cdecl("__gfx_sk2_init")
func __gfx_sk2_init(_ isDebugPtr: UnsafePointer<CChar>, _ isClientVerifyPtr: UnsafePointer<CChar>) {
    guard #available(iOS 15.0, *) else { return }

    isDebug = (String(cString: isDebugPtr) as NSString).boolValue
    isClientVerify = (String(cString: isClientVerifyPtr) as NSString).boolValue

    Task {
        do {
            let storeProducts = try await Product.products(for: productIds)
            products.removeAll()
            for p in storeProducts {
                products[p.id] = p
            }
            let json = productsToJson(storeProducts)
            sendMessage(json, code: kQueryProductsSuccess)
            sk2IsReady = true
            startTransactionUpdates()
        } catch {
            sendMessage(error.localizedDescription, code: kQueryProductsFail)
            sendMessage(error.localizedDescription, code: kInitFail)
        }
    }
}

@_cdecl("__gfx_sk2_isReady")
func __gfx_sk2_isReady() -> UnsafeMutablePointer<CChar> {
    return strdup(sk2IsReady ? "true" : "false")!
}

@_cdecl("__gfx_sk2_buy")
func __gfx_sk2_buy(_ productIdPtr: UnsafePointer<CChar>,
                    _ paymentTypePtr: UnsafePointer<CChar>,
                    _ obfuscatedAccountIdPtr: UnsafePointer<CChar>,
                    _ offerTokenPtr: UnsafePointer<CChar>,
                    _ obfuscatedProfileIdPtr: UnsafePointer<CChar>) {
    guard #available(iOS 15.0, *) else { return }
    guard sk2IsReady else {
        sendMessage("StoreKit 2 not initialized", code: kPurchaseFail)
        return
    }

    let productId = String(cString: productIdPtr)
    guard let product = products[productId] else {
        sendMessage(productId, code: kPurchaseFail)
        return
    }

    let accountId = String(cString: obfuscatedAccountIdPtr)

    Task {
        do {
            var options: Set<Product.PurchaseOption> = []
            if let token = uuidFromAccountId(accountId) {
                options.insert(.appAccountToken(token))
            }

            let result = try await product.purchase(options: options)

            switch result {
            case .success(let verification):
                let transaction: Transaction

                if isClientVerify {
                    switch verification {
                    case .verified(let tx):
                        transaction = tx
                        sendMessage(transaction.productID, code: kPurchaseCheckSuccess)
                    case .unverified(_, let error):
                        sendMessage(productId, code: kPurchaseFail)
                        sendMessage("JWS verification failed: \(error.localizedDescription)", code: kPurchaseCheckFail)
                        return
                    }
                } else {
                    switch verification {
                    case .verified(let tx):
                        transaction = tx
                    case .unverified(let tx, _):
                        transaction = tx
                    }
                }

                let txId = String(transaction.id)
                pendingTransactions[txId] = transaction
                sendMessage(purchaseJson(productId: transaction.productID, receipt: txId), code: kPurchaseSuccess)

            case .userCancelled:
                sendMessage(productId, code: kPurchaseCancel)

            case .pending:
                sendMessage(productId, code: kPurchaseFail)

            @unknown default:
                sendMessage(productId, code: kPurchaseFail)
            }
        } catch StoreKitError.userCancelled {
            sendMessage(productId, code: kPurchaseCancel)
        } catch {
            sendMessage("Purchase error: \(error.localizedDescription)", code: kPurchaseFail)
        }
    }
}

@_cdecl("__gfx_sk2_consume")
func __gfx_sk2_consume(_ purchaseTokenPtr: UnsafePointer<CChar>) {
    guard #available(iOS 15.0, *) else { return }

    let token = String(cString: purchaseTokenPtr)

    Task {
        if let transaction = pendingTransactions.removeValue(forKey: token) {
            await transaction.finish()
        }
        sendMessage(token, code: kConsumeSuccess)
    }
}

@_cdecl("__gfx_sk2_query_purchases")
func __gfx_sk2_query_purchases(_ paymentTypePtr: UnsafePointer<CChar>) {
    guard #available(iOS 15.0, *) else {
        sendMessage("[]", code: kQueryPurchasesSuccess)
        return
    }

    Task {
        do {
            var purchaseList: [[String: Any]] = []
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    let record: [String: Any] = [
                        "productId": transaction.productID,
                        "purchaseState": 1,
                        "purchaseTime": Int(transaction.purchaseDate.timeIntervalSince1970 * 1000)
                    ]
                    purchaseList.append(record)
                }
            }

            if let data = try? JSONSerialization.data(withJSONObject: purchaseList, options: [.prettyPrinted]),
               let json = String(data: data, encoding: .utf8) {
                sendMessage(json, code: kQueryPurchasesSuccess)
            } else {
                sendMessage("[]", code: kQueryPurchasesSuccess)
            }
        } catch {
            sendMessage(error.localizedDescription, code: kQueryPurchasesFail)
        }
    }
}

@_cdecl("__gfx_sk2_restore")
func __gfx_sk2_restore() {
    guard #available(iOS 15.0, *) else { return }

    Task {
        do {
            try await AppStore.sync()

            var purchaseList: [[String: Any]] = []
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    let productId = transaction.productID

                    // Send Restored callback (matches SK1 IAPToolRestoredProductID behavior)
                    sendToUnity(productId, method: "Restored")

                    let record: [String: Any] = [
                        "productId": productId,
                        "purchaseState": 1,
                        "purchaseTime": Int(transaction.purchaseDate.timeIntervalSince1970 * 1000)
                    ]
                    purchaseList.append(record)
                }
            }

            if let data = try? JSONSerialization.data(withJSONObject: purchaseList, options: [.prettyPrinted]),
               let json = String(data: data, encoding: .utf8) {
                sendMessage(json, code: kQueryPurchasesSuccess)
            } else {
                sendMessage("[]", code: kQueryPurchasesSuccess)
            }
        } catch {
            sendMessage(error.localizedDescription, code: kQueryPurchasesFail)
        }
    }
}
