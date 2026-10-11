import Foundation

public struct FetchHomeCurationSectionInput: Encodable {
    public let mapLatitude: Double
    public let mapLongitude: Double

    public init(mapLatitude: Double, mapLongitude: Double) {
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
    }
}
