import Foundation

import Model

enum FeedbackApi {
    case sendFeedbacks(targetType: String, targetId: String, feedbackTypes: [FeedbackType])
    case fetchMyStoreFeedbacks(input: CursorRequestInput)
}

extension FeedbackApi: RequestType {
    var param: Encodable? {
        switch self {
        case .sendFeedbacks(_, _, let feedbackTypes):
            return ["feedbackTypes": feedbackTypes.map { $0.rawValue }]
        case .fetchMyStoreFeedbacks(let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .sendFeedbacks:
            return .post
        case .fetchMyStoreFeedbacks:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .sendFeedbacks:
            return .auth
        case .fetchMyStoreFeedbacks:
            return .auth
        }
    }
    
    var path: String {
        switch self {
        case .sendFeedbacks(let targetType, let targetId, _):
            return "/api/v1/feedback/\(targetType)/target/\(targetId)"
        case .fetchMyStoreFeedbacks:
            return "/api/v1/my/store-feedbacks"
        }
    }
}
