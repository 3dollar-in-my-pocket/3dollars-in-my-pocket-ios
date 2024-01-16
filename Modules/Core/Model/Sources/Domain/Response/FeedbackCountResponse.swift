import Foundation

public struct FeedbackCountResponse: Decodable {
    public let count: Int
    public let feedbackType: FeedbackType
}
