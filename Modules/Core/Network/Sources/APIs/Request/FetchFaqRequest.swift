import Foundation

import Model

struct FetchFaqRequest: RequestType {
    let category: String?
    
    var param: Encodable? {
        guard let category else { return nil }
        
        return ["category": category]
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/v2/faqs"
    }
}
