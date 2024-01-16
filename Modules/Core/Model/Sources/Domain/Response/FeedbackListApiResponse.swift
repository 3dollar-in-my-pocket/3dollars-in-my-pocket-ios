import Foundation

public struct FeedbackListApiResponse: Decodable {
    public let store: PlatformStoreResponse
    public let date: String
    public let feedbacks: [FeedbackCountResponse]
}
