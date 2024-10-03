import Foundation

import Model

public protocol FeedbackRepository {
    func sendFeedbacks(targetType: String, targetId: String, feedbackTypes: [FeedbackType]) async -> Result<String?, Error>
    
    func fetchMyStoreFeedbacks(input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<FeedbackListApiResponse>, Error>
}

public struct FeedbackRepositoryImpl: FeedbackRepository {
    public init() { }

    public func sendFeedbacks(targetType: String, targetId: String, feedbackTypes: [FeedbackType]) async -> Result<String?, Error> {
        let request = FeedbackApi.sendFeedbacks(targetType: targetType, targetId: targetId, feedbackTypes: feedbackTypes)

        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchMyStoreFeedbacks(input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<FeedbackListApiResponse>, Error> {
        let request = FeedbackApi.fetchMyStoreFeedbacks(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
