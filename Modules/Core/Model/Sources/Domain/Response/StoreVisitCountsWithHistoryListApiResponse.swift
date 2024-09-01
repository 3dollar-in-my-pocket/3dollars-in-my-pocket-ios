import Foundation

public struct StoreVisitCountsWithHistoryListApiResponse: Decodable {
    public let histories: ContentsWithCursorResponse<StoreVisitWithUserApiResponse>
    public let counts: StoreVisitCountResponse
}
