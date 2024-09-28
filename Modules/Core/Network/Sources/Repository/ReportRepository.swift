import Foundation

import Model

public protocol ReportRepository {
    func fetchReportReasons(group: ReportGroup) async -> Result<ReportReasonApiResponse, Error>
}

public struct ReportRepositoryImpl: ReportRepository {
    public init() { }
    
    public func fetchReportReasons(group: ReportGroup) async -> Result<ReportReasonApiResponse, Error> {
        let request = ReportApi.fetchReportReasons(group: group)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
