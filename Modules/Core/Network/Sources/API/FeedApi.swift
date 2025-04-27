import Foundation

import Model

enum FeedApi {
    case fetchFeeds(ticketId: String, input: FetchFeedInput)
}

extension FeedApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchFeeds(_, let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchFeeds:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchFeeds:
            return .location
        }
    }
    
    var path: String {
        switch self {
        case .fetchFeeds(let ticketId, _):
            return "/api/v1/feed-ticket/\(ticketId)/feeds"
        }
    }
}
