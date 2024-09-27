import Foundation

import Model

enum ReportApi {
    case fetchReportReasons(group: ReportGroup)
}

extension ReportApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchReportReasons:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchReportReasons:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchReportReasons:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .fetchReportReasons(let group):
            return "/api/v1/report/group/\(group.rawValue)/reasons"
        }
    }
}
