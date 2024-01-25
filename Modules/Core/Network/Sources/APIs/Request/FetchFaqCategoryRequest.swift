import Foundation

import Model

struct FetchFaqCategoryRequest: RequestType {
    var param: Encodable? {
        return nil
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/v2/faq/categories"
    }
}
