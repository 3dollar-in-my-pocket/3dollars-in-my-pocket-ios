import Foundation

public protocol RequestType {
    var param: Encodable? { get }
    var method: RequestMethod { get }
    var header: HTTPHeaderType { get }
    var path: String { get }
    var usingQuery: Bool { get }
}

public extension RequestType {
    var param: Encodable? {
        return nil
    }
    
    var usingQuery: Bool {
        switch method {
        case .get, .delete:
            return true
            
        case .post, .put, .patch:
            return false
        }
    }
    
    var queryItems: [URLQueryItem]? {
        if let param = param,
           let dictionary = param.dictionary {
            return dictionary.map {
                var value = ""
                if let arrayValue = $0.value as? [String] {
                    value = arrayValue.joined(separator: ",")
                } else {
                    value = String(describing: $0.value)
                }
                return URLQueryItem(name: $0.key, value: value)
            }
        } else {
            return nil
        }
    }
    
    var body: Data? {
        guard let param = param,
              let data = try? JSONEncoder().encode(param) else {
            return nil
        }
        
        return data
    }

    var header: HTTPHeaderType {
        return .json
    }
}
