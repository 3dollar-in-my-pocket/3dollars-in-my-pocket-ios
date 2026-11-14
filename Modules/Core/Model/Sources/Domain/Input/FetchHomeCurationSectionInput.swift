import Foundation

public struct FetchHomeCurationSectionInput: Encodable {
    public let mapLatitude: Double
    public let mapLongitude: Double
    public let maxDistanceM: Double?

    public init(mapLatitude: Double, mapLongitude: Double, maxDistanceM: Double? = nil) {
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
        self.maxDistanceM = maxDistanceM
    }
}
