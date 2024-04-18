import Foundation

import Model

struct DeleteMyPlaceRequest: RequestType {
    let placeType: PlaceType
    let placeId: String
    
    var param: Encodable? {
        return ["placeId": placeId]
    }
    
    var method: RequestMethod {
        return .delete
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/my/\(placeType.rawValue)/place/\(placeId)"
    }
}

