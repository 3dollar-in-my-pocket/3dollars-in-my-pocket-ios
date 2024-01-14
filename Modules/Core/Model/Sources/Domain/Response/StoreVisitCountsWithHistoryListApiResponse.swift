import Foundation

public struct StoreVisitCountsWithHistoryListApiResponse: Decodable {
    public let histories: ContentsWithCursorResposne<StoreVisitWithUserApiResponse>
    public let counts: StoreVisitCountResponse
}
