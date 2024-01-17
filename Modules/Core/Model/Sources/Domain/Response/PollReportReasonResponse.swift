import Foundation

public struct PollReportReasonResponse: Decodable {
    public let reasons: [PollReportReason]
}
