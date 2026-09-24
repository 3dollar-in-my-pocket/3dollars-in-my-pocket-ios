import Foundation

import Model
import Networking

final class MockReportRepository: ReportRepository {
    var fetchReportReasonsResult: Result<ReportReasonApiResponse, Error> = .failure(MockError.notStubbed())

    init(fetchReportReasonsResult: Result<ReportReasonApiResponse, Error>? = nil) {
        if let fetchReportReasonsResult {
            self.fetchReportReasonsResult = fetchReportReasonsResult
        }
    }

    func fetchReportReasons(group: ReportGroup) async -> Result<ReportReasonApiResponse, Error> {
        fetchReportReasonsResult
    }
}
