import Foundation

import Model

enum Deeplink {
    case bookmark(folderId: String)
    case storeDetail(storeType: StoreType, storeId: String)
    case home
    case medal
    case pollDetail(pollId: String)
    case accountInfo
    case myCoupons

    var type: DeeplinkPath {
        switch self {
        case .bookmark:
            return .bookmark
            
        case .storeDetail:
            return .store
            
        case .home:
            return .home
            
        case .medal:
            return .medal

        case .pollDetail:
            return .community
            
        case .accountInfo:
            return .accountInfo
            
        case .myCoupons:
            return .myCoupons
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .bookmark(let folderId):
            return ["folderId": folderId]
            
        case .storeDetail(let storeType, let storeId):
            return [
                "storeType": storeType.rawValue,
                "storeId": storeId
            ]
        case .pollDetail(let pollId):
            return [
                "pollId": pollId
            ]
        default:
            return nil
        }
    }
    
    var url: URL? {
        var component = URLComponents(string: Bundle.dynamiclinkHost + "/" + type.path + "?")
        
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
