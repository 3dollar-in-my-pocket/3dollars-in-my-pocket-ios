import Foundation

public struct FeedbackListApiResponse: Decodable {
    public let store: StoreApiResponse
    public let date: String
    public let feedbacks: [FeedbackCountResponse]
}
