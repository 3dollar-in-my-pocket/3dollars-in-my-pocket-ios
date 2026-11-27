import Foundation

public struct FetchHomeNewsSectionInput: Encodable, Equatable {
    public let mapLatitude: Double
    public let mapLongitude: Double
    public let maxDistanceM: Double?
    public let cursor: String?

    public init(mapLatitude: Double, mapLongitude: Double, maxDistanceM: Double? = nil, cursor: String? = nil) {
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
        self.maxDistanceM = maxDistanceM
        self.cursor = cursor
    }
}
