public struct PollReportReason: Decodable, Equatable {
    public let type: String
    public let description: String
    public let hasReasonDetail: Bool

    public static func == (lhs: PollReportReason, rhs: PollReportReason) -> Bool {
        return lhs.type == rhs.type && lhs.description == rhs.description && lhs.hasReasonDetail == rhs.hasReasonDetail
    }
}
