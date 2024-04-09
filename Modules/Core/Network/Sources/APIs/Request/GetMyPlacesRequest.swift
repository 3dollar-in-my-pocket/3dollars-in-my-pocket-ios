import Foundation

import Model

struct GetMyPlacesRequest: RequestType {
    let placeType: PlaceType
    let input: CursorRequestInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/my/\(placeType.rawValue)/places"
    }
}
