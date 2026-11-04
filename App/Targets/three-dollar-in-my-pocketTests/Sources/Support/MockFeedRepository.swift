import Foundation

import Model
import Networking

final class MockFeedRepository: FeedRepository {
    private let lock = NSLock()
    private var _fetchFeedResults: [Result<ContentsWithCursorResponse<FeedResponse>, Error>] = []
    private var _requestedInputs: [FetchFeedInput] = []

    var fetchFeedResults: [Result<ContentsWithCursorResponse<FeedResponse>, Error>] {
        get { lock.withLock { _fetchFeedResults } }
        set { lock.withLock { _fetchFeedResults = newValue } }
    }

    var requestedInputs: [FetchFeedInput] {
        lock.withLock { _requestedInputs }
    }

    func fetchFeed(input: FetchFeedInput) async -> Result<ContentsWithCursorResponse<FeedResponse>, Error> {
        lock.withLock {
            _requestedInputs.append(input)
            if _fetchFeedResults.isEmpty { return .failure(MockError.notStubbed()) }
            return _fetchFeedResults.count == 1 ? _fetchFeedResults[0] : _fetchFeedResults.removeFirst()
        }
    }
}
