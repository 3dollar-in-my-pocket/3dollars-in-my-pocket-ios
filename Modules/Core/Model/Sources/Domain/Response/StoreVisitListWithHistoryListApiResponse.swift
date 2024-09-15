import Foundation

public struct StoreVisitListWithCountResponse: Decodable {
    public let histories: ContentsWithCursorResponse<StoreVisitWithUserResponse>
    public let counts: StoreVisitCountResponse
}
