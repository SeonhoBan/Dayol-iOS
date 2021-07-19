//
//  IAPReceipt.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/07/11.
//

import Foundation

extension API {
    struct IAPReceiptAPI: APIPostRequest {
        typealias Response = MembershipReceipt

        struct MembershipReceipt: Decodable {
            let status: Int
            let latestReceipt: String
            let latestReceiptInfo: [LatestReceiptInfo]
            let receipt: Receipt

            enum CodingKeys: String, CodingKey {
                case status
                case latestReceipt = "latest_receipt"
                case latestReceiptInfo = "latest_receipt_info"
                case receipt
            }
        }

        struct LatestReceiptInfo: Decodable {
            let purchaseAt: String
            let expireAt: String

            enum CodingKeys: String, CodingKey {
                case purchaseAt = "purchase_date_ms"
                case expireAt = "expires_date_ms"
            }
        }

        struct Receipt: Decodable {
            let adamId: Int
            let createAt: String

            enum CodingKeys: String, CodingKey {
                case adamId = "adam_id"
                case createAt = "receipt_creation_date"
            }
        }

        var baseURL: String = Config.shared.inAppPurchaseURL

        var parameters: [String : Any] {
            var parameters: [String: Any] = [:]

            guard
                let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                let receiptString = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped).base64EncodedString(options: []),
                FileManager.default.fileExists(atPath: appStoreReceiptURL.path)
            else {
                DYLog.e(.inAppPurchase, in: Self.self, value: "Receipt Error")
                return parameters
            }

            parameters["receipt-data"] = receiptString
            parameters["password"] = password
            parameters["exclude-old-transactions"] = true
            return parameters
        }

        let password: String

        func parse(_ response: Any) -> API.Result<Response> {
            guard Config.shared.isProd else { return .failure(Config.InternalError.notProduct) }
            guard let json = response as? [AnyHashable: Any] else {
                DYLog.e(.inAppPurchase, in: Self.self, value: response)
                return .failure(API.ResponseError.parse)
            }

//            let jsonData = try! JSONSerialization.data(withJSONObject: json)
//            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
//               print(JSONString)
//            }

            if let membershipReceipt = json.data?.decode(MembershipReceipt.self) {
                DYLog.i(.inAppPurchase, in: Self.self, value: membershipReceipt.latestReceiptInfo)
                return .success(membershipReceipt)
            } else {
                DYLog.e(.inAppPurchase, in: Self.self, value: response)
                return .failure(API.ResponseError.parse)
            }
        }
    }
}
