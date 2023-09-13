import Foundation

public struct StoreDetailVisit: Hashable {
    public let existsCounts: Int
    public let notExistsCounts: Int
    public let histories: [StoreVisitHistory]
    
    public init(response: StoreVisitCountsWithHistoryListApiResponse) {
        self.existsCounts = response.counts.existsCounts
        self.notExistsCounts = response.counts.notExistsCounts
        self.histories = response.histories.contents.map { StoreVisitHistory(response: $0) }
    }
}
