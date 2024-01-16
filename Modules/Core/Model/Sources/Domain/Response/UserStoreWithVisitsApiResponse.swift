import Foundation

public struct UserStoreWithVisitsApiResponse: Decodable {
    public let store: UserStoreApiResponse
    public let distanceM: Int
    public let visits: CountResponse
}

extension UserStoreWithVisitsApiResponse {
    public struct CountResponse: Decodable {
        public let count: StoreVisitCountResponse
    } 
}
