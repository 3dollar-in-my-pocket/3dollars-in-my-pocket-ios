import Foundation

import Model

struct FetchReportReasonListRequest: RequestType {
    let group: ReportGroup
    
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
        return "/api/v1/report/group/\(group.rawValue)/reasons"
    }
}
