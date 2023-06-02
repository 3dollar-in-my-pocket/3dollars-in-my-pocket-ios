import Foundation

public protocol RequestType {
    var param: [String: Any]? { get }
    var method: RequestMethod { get }
    var header: HTTPHeaderType { get }
    var path: String { get }
}

extension RequestType {
    var queryItems: [URLQueryItem]? {
        if let param = param {
            return param.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        } else {
            return nil
        }
    }
    
    var body: Data? {
        guard let param = param,
              let data = try? JSONSerialization.data(withJSONObject: param, options: []) else {
            return nil
        }
        
        return data
    }

    var header: HTTPHeaderType {
        return .json
    }
}
