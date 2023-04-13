import Foundation

enum Deeplink {
    case bookmark(folderId: String)
    case storeDetail(storeType: StoreType, storeId: String)
    
    var type: DeeplinkType {
        switch self {
        case .bookmark:
            return .bookmark
        case .storeDetail:
            return .store
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .bookmark(let folderId):
            return ["folderId": folderId]
        case .storeDetail(let storeType, let storeId):
            return [
                "storeType": storeType.targetType,
                "storeId": storeId
            ]
        }
    }
    
    var url: URL? {
        var component = URLComponents(string: Bundle.dynamiclinkHost + type.path + "?")
        
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
