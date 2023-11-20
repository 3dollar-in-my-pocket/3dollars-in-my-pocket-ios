import Foundation

import Model

struct ReportReviewRequest: RequestType {
    let storeId: Int
    let reviewId: Int
    let input: ReportReviewRequestInput
    
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
        return "/api/v1/store/\(storeId)/review/\(reviewId)/report"
    }
}
