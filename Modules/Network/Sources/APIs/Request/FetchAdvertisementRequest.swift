import Foundation

struct FetchAdvertisementRequest: RequestType {
    let input: FetchAdvertisementInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/v1/advertisements"
    }
}
