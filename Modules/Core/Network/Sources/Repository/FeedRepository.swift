import Foundation

import Model

public protocol FeedRepository {
    func fetchFeed(input: FetchFeedInput) async -> Result<ContentsWithCursorResponse<FeedResponse>, Error>
}

public final class FeedRepositoryImpl: FeedRepository {
    public init() { }
    
    public func fetchFeed(input: FetchFeedInput) async -> Result<ContentsWithCursorResponse<FeedResponse>, Error> {
        let request = FeedApi.fetchFeeds(ticketId: "LOCAL_NEWS", input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
