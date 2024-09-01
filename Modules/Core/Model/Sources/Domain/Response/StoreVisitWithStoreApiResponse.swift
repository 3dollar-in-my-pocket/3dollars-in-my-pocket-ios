import Foundation

public struct StoreVisitWithStoreApiResponse: Decodable {
    public let visit: StoreVisitApiResponse
    public let store: StoreResponse
}
