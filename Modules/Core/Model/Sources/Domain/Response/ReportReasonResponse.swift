import Foundation

public struct ReportReasonResponse: Decodable {
    public let type: String
    public let description: String
    public let hasReasonDetail: Bool
}
