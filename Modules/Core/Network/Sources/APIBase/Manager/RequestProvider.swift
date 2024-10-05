import Foundation

import DependencyInjection
import Model

final class RequestProvider {
    private var config: NetworkConfigurable
    private let sesseion: URLSession

    init() {
        guard let config = DIContainer.shared.container.resolve(NetworkConfigurable.self) else {
            fatalError("⚠️ NetworkConfigurable가 등록되지 않았습니다.")
        }
        self.config = config

        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = config.timeoutForRequest
        defaultConfiguration.timeoutIntervalForResource = config.timeoutForResource
        
        self.sesseion = URLSession(configuration: defaultConfiguration)
    }

    func request(requestType: RequestType) async throws -> (Data, URLResponse) {
        let request = try generateURLRequest(requestType: requestType)
        
        NetworkLogger.logRequest(request: request)
        
        return try await sesseion.data(for: request)
    }
    
    private func generateURLRequest(requestType: RequestType) throws -> URLRequest {
        var urlComponents = URLComponents(string: config.endPoint)
        urlComponents?.path = requestType.path
        
        if requestType.usingQuery || requestType.method == .get {
            if let queryItems = requestType.queryItems, !queryItems.isEmpty {
                urlComponents?.queryItems = queryItems
            }
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.method.rawValue
        urlRequest.allHTTPHeaderFields = generateHeader(type: requestType.header)
        
        switch requestType.header {
        case .multipart:
            urlRequest.httpBody = (requestType as? MultipartRequestType)?.data
            
        default:
            if !requestType.usingQuery && requestType.method != .get {
                urlRequest.httpBody = requestType.body
            }
        }
        
        return urlRequest
    }
    
    private func generateHeader(type: HTTPHeaderType) -> [String: String] {
        var header = [
            "Accept": "application/json",
            "User-Agent": config.userAgent
        ]
        
        switch type {
        case .json:
            header["Content-Type"] = "application/json"
        case .multipart(let boundary):
            header["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
            if let authToken = config.authToken {
                header["Authorization"] = authToken
            }
        case .location:
            header["Content-Type"] = "application/json"
            header["X-Device-Latitude"] = String(config.userCurrentLocation.coordinate.latitude)
            header["X-Device-Longitude"] = String(config.userCurrentLocation.coordinate.longitude)
        case .custom(let dict):
            header["Content-Type"] = "application/json"
            dict.forEach { key, value in
                header[key] = value
            }
        }
        
        if let authToken = config.authToken {
            header["Authorization"] = authToken
        }
        
        return header
    }
}
