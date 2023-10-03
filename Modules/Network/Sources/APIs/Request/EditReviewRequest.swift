import Foundation

import Model

struct EditReviewRequest: RequestType {
    let reviewId: Int
    let input: EditReviewRequestInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .put
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/v2/store/review/\(reviewId)"
    }
}
