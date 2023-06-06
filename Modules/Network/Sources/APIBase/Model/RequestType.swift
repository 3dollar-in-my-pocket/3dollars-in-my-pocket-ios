import Foundation

public protocol RequestType {
    var param: Encodable? { get }
    var method: RequestMethod { get }
    var header: HTTPHeaderType { get }
    var path: String { get }
}

extension RequestType {
    var queryItems: [URLQueryItem]? {
        if let param = param,
           let dictionary = param.dictionary {
            return dictionary.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
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
