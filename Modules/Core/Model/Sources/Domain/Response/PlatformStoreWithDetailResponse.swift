import Foundation

public struct PlatformStoreWithDetailResponse: Decodable {
    public let store: StoreApiResponse
    public let distanceM: Int
    public let extra: PlatformStoreExtraResponse
}
