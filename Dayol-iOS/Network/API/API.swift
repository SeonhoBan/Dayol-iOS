//
//  API.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/07/10.
//

import Foundation
import RxSwift

// MARK: - API, API Request
struct API {
    static var version: Int = 1

    enum Body {
        case json
        case url(parameters: [String: Any])

        static let headerField: String = "Content-Type"

        var contentType: String {
            switch self {
            case .json: return "application/json"
            case .url: return "application/x-www-form-urlencoded"
            }
        }

        var data: Data? {
            switch self {
            case .json: return nil
            case .url(let parameters): return parameters.data
            }
        }
    }

    enum Result<T> {
        case success(T)
        case failure(Error)
    }

    enum InternalError: Error {
        case createURL
    }

    enum ResponseError: Error {
        case parse
    }
}

protocol APIRequest: ReactiveCompatible {
    associatedtype Response
    var requestMethod: String { get }
    var baseURL: String { get }
    var body: API.Body? { get }
    var path: String { get }
    var parameters: [String: Any] { get }
    func parse(_ response: Any) -> API.Result<Response>
}
extension APIRequest {
    fileprivate var timeoutInterval: TimeInterval { return 30.0 }
    var requestMethod: String { return "" }
    var body: API.Body? { return nil }
    var path: String { return "" }
    var parameters: [String: Any] { return [:] }
}

extension APIRequest {
    fileprivate func createRequest() -> Single<Response> {
        return Single.just(baseURL + path)
            .map { (urlPath: String) -> URL in
                if let url = URL(string: urlPath) {
                    return url
                } else {
                    throw API.InternalError.createURL
                }
            }
            .map { (url: URL) -> URLRequest in
                var requset = URLRequest(url: url)
                requset.httpMethod = self.requestMethod
                requset.timeoutInterval = self.timeoutInterval
                requset.setValue(body?.contentType, forHTTPHeaderField: API.Body.headerField)
                requset.httpBody = body?.data
                return requset
            }
            .flatMap { (urlRequlst: URLRequest) -> Single<Any> in
                return URLSession.shared.rx.json(request: urlRequlst).asSingle()
            }
            .map { (response: Any) -> Any in
                if let dictionary = response as? [String: Any]  {
                    return dictionary
                } else {
                    return response
                }
            }
            .map{ response -> Response in
                switch self.parse(response) {
                case .success(let response):
                    return response
                case .failure(let error):
                    throw error
                }
            }
            .catch(self.errorHandler)
    }

    fileprivate func errorHandler(error: Swift.Error) -> Single<Response> {
        DYLog.e(.api, in: Self.self, value: error)
        return .error(error)
    }
}

protocol APIGetRequest: APIRequest {}
extension APIGetRequest {
    var requestMethod: String { return "GET" }
    var body: API.Body? { return nil }
    var path: String { return "" }
}

protocol APIPostRequest: APIRequest {}
extension APIPostRequest {
    var requestMethod: String { return "POST" }
    var body: API.Body? { return .url(parameters: parameters) }
    var path: String { return "" }
}


// MARK: - Rx Extension

extension Reactive where Base: APIRequest {
    func response() -> Single<Base.Response> {
        return base.createRequest()
    }
}
