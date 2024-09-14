import Foundation

public struct StoreVisitWithStoreApiResponse: Decodable {
    public let visit: StoreVisitResponse
    public let store: StoreResponse
}
