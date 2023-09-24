import Foundation

public struct PollReportCreateRequestInput: Encodable {
    public let reason: String
    public let reasonDetail: String?

    public init(reason: String, reasonDetail: String?) {
        self.reason = reason
        self.reasonDetail = reasonDetail
    }
}
