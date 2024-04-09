import Foundation

import Model

struct SaveMyPlaceRequest: RequestType {
    let placeType: PlaceType
    let input: SaveMyPlaceInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/my/\(placeType.rawValue)/place"
    }
}
