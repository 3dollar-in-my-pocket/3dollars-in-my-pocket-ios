import Foundation

public struct PlatformStoreWithDetailResponse: Decodable {
    public let store: PlatformStoreResponse
    public let distanceM: Int
    public let extra: PlatformStoreExtraResponse
}
