import Foundation

public struct ReportReason: Hashable {
    public let type: String
    public let description: String
    public let hasReasonDetail: Bool
    
    public init(response: ReportReasonResponse) {
        self.type = response.type
        self.description = response.description
        self.hasReasonDetail = response.hasReasonDetail
    }
}
