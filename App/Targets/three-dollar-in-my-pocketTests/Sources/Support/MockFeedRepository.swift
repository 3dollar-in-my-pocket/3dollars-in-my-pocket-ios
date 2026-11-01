import Foundation

import Model
import Networking

final class MockFeedRepository: FeedRepository {
    var fetchFeedResults: [Result<ContentsWithCursorResponse<FeedResponse>, Error>] = []
    private(set) var requestedInputs: [FetchFeedInput] = []

    func fetchFeed(input: FetchFeedInput) async -> Result<ContentsWithCursorResponse<FeedResponse>, Error> {
        requestedInputs.append(input)
        if fetchFeedResults.isEmpty { return .failure(MockError.notStubbed()) }
        return fetchFeedResults.count == 1 ? fetchFeedResults[0] : fetchFeedResults.removeFirst()
    }
}
