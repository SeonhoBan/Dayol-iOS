//
//  IAPManager.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/06/20.
//

import Foundation
import StoreKit
import RxSwift

// MARK: - IAP Product Type

enum IAPProductType {
    case autoSubscription
    enum AutoSubscriptionProduct: CaseIterable {
        case membershipYear
        case membershipMonth

        init?(identifier: String) {
            switch identifier {
            case AutoSubscriptionProduct.membershipYear.identifier: self = .membershipYear
            case AutoSubscriptionProduct.membershipMonth.identifier: self = .membershipMonth
            default: return nil
            }
        }

        private static let bundleIdentifier: String = {
            guard Config.shared.isProd else { return "com.dayolstudio.dayol" }
            return Bundle.main.bundleIdentifier ?? ""
        }()

        static var identifiers: Set<String> {
            var identifiers: Set<String> = []
            Self.allCases.forEach {
                identifiers.insert([Self.bundleIdentifier, $0.toString].joined(separator: "."))
            }

            return identifiers
        }

        var toString: String {
            switch self {
            case .membershipYear: return "membership.year"
            case .membershipMonth: return "membership.month"
            }
        }

        var identifier: String {
            return Self.bundleIdentifier + "." + self.toString
        }
    }
}

struct IAPAutoSubscriptionResponse {
    let activityType: UserActivityType
    let expireAt: TimeInterval
}

// MARK: - IAP Manager

final class IAPManager: NSObject {
    static var shared = IAPManager()

    private let sharedSecretPassword = "a077f258292c41288a70b3c96c0a22ab"
    private let paymentQueue: SKPaymentQueue = SKPaymentQueue.default()
    private var products = [SKProduct]()
    private var disposeBag: DisposeBag = DisposeBag()

    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    let updatedProducts: PublishSubject<[SKProduct]> = PublishSubject<[SKProduct]>()
    let purchasedProduct: PublishSubject<Bool> = PublishSubject<Bool>()

    override init() {
        super.init()
        paymentQueue.add(self)
    }

    // MARK: - IAP Product Identifier
    private func productIdentifiers(type: IAPProductType) -> Set<String> {
        switch type {
        case .autoSubscription: return IAPProductType.AutoSubscriptionProduct.identifiers
        }
    }

    func fetchProducts(type: IAPProductType) {
        let request = SKProductsRequest(productIdentifiers: productIdentifiers(type: type))
        request.delegate = self
        request.start()
    }

    func purchase(product: SKProduct) {
        guard canMakePayments else { return }
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }

    func restorePurchase() {
        guard canMakePayments else { return }
        paymentQueue.restoreCompletedTransactions()
    }

    func checkPurchasedAndUpdate() -> Single<Void> {
        return API.IAPReceiptAPI(password: sharedSecretPassword).rx.response()
            .map { (response: API.IAPReceiptAPI.Response) in
                guard let receiptExpireAt = TimeInterval(response.latestReceiptInfo.first?.expireAt ?? "") else { return }
                let expireAt = receiptExpireAt / 1000
                let nowTime = Date().timeIntervalSince1970
                let isExpired = expireAt <= nowTime

                if !isExpired {
                    let response = IAPAutoSubscriptionResponse(activityType: .subscriber, expireAt: expireAt)
                    MembershipManager.shared.didChangeMembership(response: response)
                } else {
                    let response = IAPAutoSubscriptionResponse(activityType: .expiredSubscriber, expireAt: expireAt)
                    MembershipManager.shared.didChangeMembership(response: response)
                }
                return
            }
            .flatMap { _ -> Single<Void> in
                return Single<Void>.just(Void())
            }
    }
}

// MARK: - Request Delegate

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard !response.products.isEmpty else { return }
        products = response.products
        updatedProducts.onNext(response.products)

        response.products.forEach { product in
            DYLog.d(.inAppPurchase, in: Self.self, value: product.productIdentifier)
        }
    }
}

// MARK: - Payment Transaction Observer

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchasing:
                DYLog.i(.inAppPurchase, in: Self.self, value: "PURCHASING")
            case .purchased:
                checkReceiptAndUpdate()
                paymentQueue.finishTransaction(transaction)
                DYLog.i(.inAppPurchase, in: Self.self, value: "PURCHASED")
            case .failed:
                checkReceiptAndUpdate()
                purchasedProduct.onNext(false)
                paymentQueue.finishTransaction(transaction)
                DYLog.e(.inAppPurchase, in: Self.self, value: "FAILED")
            case .deferred:
                paymentQueue.finishTransaction(transaction)
                DYLog.i(.inAppPurchase, in: Self.self, value: "DEFERRED")
            case .restored:
                paymentQueue.finishTransaction(transaction)
                DYLog.i(.inAppPurchase, in: Self.self, value: "RESTORED")
            default:
                break
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DYLog.i(.inAppPurchase, in: Self.self, value: "RestoreCompletedTransactionsFinished")
    }

    private func checkReceiptAndUpdate() {
        checkPurchasedAndUpdate()
            .attachHUD()
            .subscribe { _ in
                self.purchasedProduct.onNext(true)
            }
            .disposed(by: disposeBag)
    }
}
