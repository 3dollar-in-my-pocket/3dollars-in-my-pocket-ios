import Foundation

import Model

struct ReportStoreRequest: RequestType {
    let storeId: Int
    let reportReason: String

    var param: Encodable? {
        return ["deleteReasonType": reportReason]
    }
    
    var method: RequestMethod {
        return .delete
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/store/\(storeId)"
    }
}
