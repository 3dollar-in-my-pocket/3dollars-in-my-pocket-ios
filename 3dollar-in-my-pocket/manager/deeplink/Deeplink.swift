import Foundation

enum Deeplink {
    case bookmark(folderId: String)
    
    var type: DeeplinkType {
        switch self {
        case .bookmark:
            return .bookmark
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .bookmark(let folderId):
            return ["folderId": folderId]
        }
    }
    
    var url: URL? {
        var component = URLComponents(string: Bundle.deeplinkHost + type.path + "?")
        
        if let parameters = parameters {
            for parameter in parameters {
                let queryItem = URLQueryItem(
                    name: parameter.key,
                    value: parameter.value
                )
                
                component?.queryItems?.append(queryItem)
            }
        }
        
        return component?.url
    }
}
