import Foundation

public enum HTTPError: Int, LocalizedError {
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case internalServierError = 500
    case badGateway = 502
    case maintenance = 503
    case unknown
    
    init(fromRawValue: Int) {
        self = HTTPError(rawValue: fromRawValue) ?? .unknown
    }
}
