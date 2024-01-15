import Foundation

import Model

struct SendFeedbacksRequest: RequestType {
    let targetType: String
    let targetId: String
    let feedbackTypes: [FeedbackType]

    var param: Encodable? {
        return ["feedbackTypes": feedbackTypes.map { $0.rawValue }]
    }

    var method: RequestMethod {
        return .post
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v1/feedback/\(targetType)/target/\(targetId)"
    }
}
