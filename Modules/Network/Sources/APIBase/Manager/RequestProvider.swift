import Foundation

final class RequestProvider {
    var config: NetworkConfiguration
    private let sesseion: URLSession

    init(config: NetworkConfiguration) {
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
        
        if requestType.method == .get,
           let queryItems = requestType.queryItems {
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.method.rawValue
        urlRequest.allHTTPHeaderFields = generateHeader(type: requestType.header)
        
        if requestType.method == .post {
            urlRequest.httpBody = requestType.body
        }
        return urlRequest
    }
    
    private func generateHeader(type: HTTPHeaderType) -> [String: String] {
        var header = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "User-Agent": config.userAgent
        ]
        
        switch type {
        case .json:
            break
            
        case .auth:
            if let authToken = config.authToken {
                header["Authorization"] = authToken
            }
            
        case .custom(let dict):
            if let authToken = config.authToken {
                header["Authorization"] = authToken
            }
            dict.forEach { key, value in
                header[key] = value
            }
        }
        
        return header
    }
}
