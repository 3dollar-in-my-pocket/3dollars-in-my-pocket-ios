import Foundation

public struct FeedbackListApiResponse: Decodable {
    public let store: StoreResponse
    public let date: String
    public let feedbacks: [FeedbackCountResponse]
}
