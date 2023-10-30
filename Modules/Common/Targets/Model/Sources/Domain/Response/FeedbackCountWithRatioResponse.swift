import Foundation

public struct FeedbackCountWithRatioResponse: Decodable {
    public let count: Int
    public let feedbackType: FeedbackType
    public let ratio: Double
}
