import Foundation

public struct PlatformStoreWithDetailResponse: Decodable {
    let store: PlatformStoreResponse
    let distanceM: Int
    let extra: PlatformStoreExtraResponse
}
