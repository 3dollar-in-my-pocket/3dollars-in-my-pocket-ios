import Foundation

public struct UserStoreWithVisitsResponse: Decodable {
    public let store: UserStoreResponse
    public let distanceM: Int
    public let visits: StoreVisitCountSimpleResponse
    public let tags: StoreTagResponse
}

extension UserStoreWithVisitsResponse {
    public struct StoreVisitCountSimpleResponse: Decodable {
        public let count: StoreVisitCountResponse
    } 
}
