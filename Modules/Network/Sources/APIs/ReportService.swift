import Foundation

import Model

public protocol ReportServiceProtocol {
    func fetchReportReasons(group: ReportGroup) async -> Result<ReportReasonApiResponse, Error>
}

public struct ReportService: ReportServiceProtocol {
    public init() { }
    
    public func fetchReportReasons(group: ReportGroup) async -> Result<ReportReasonApiResponse, Error> {
        let request = FetchReportReasonListRequest(group: group)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
