import Foundation

public struct MyStoreFeedback: Hashable {
    public let store: PlatformStore
    public let date: String
    public let feedbacks: [Feedback]
    
    public init(response: FeedbackListApiResponse) {
        self.store = PlatformStore(response: response.store)
        self.date = response.date
        self.feedbacks = response.feedbacks.map { Feedback(response: $0) }
    }
}

public extension MyStoreFeedback {
    struct Feedback: Hashable {
        public let feedbackType: FeedbackType
        public let count: Int
        
        public init(response: FeedbackCountResponse) {
            self.feedbackType = response.feedbackType
            self.count = response.count
        }
    }
}
