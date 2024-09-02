import Foundation

public struct PlatformStoreWithDetailResponse: Decodable {
    public let store: StoreResponse
    public let distanceM: Int
    public let extra: PlatformStoreExtraResponse
}
