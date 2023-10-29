import Foundation

public struct FetchBossStoreDetailInput: Encodable {
    public let storeId: String
    public let latitude: Double
    public let longitude: Double

    public init(
        storeId: String,
        latitude: Double,
        longitude: Double
    ) {
        self.storeId = storeId
        self.latitude = latitude
        self.longitude = longitude
    }
}
