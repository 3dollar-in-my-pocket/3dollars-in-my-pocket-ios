import Foundation

import Model

struct WriteReviewRequest: RequestType {
    let input: WriteReviewRequestInput

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
        return "/api/v3/store/review"
    }
}
