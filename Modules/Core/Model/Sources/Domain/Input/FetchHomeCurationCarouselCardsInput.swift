import Foundation

public struct FetchHomeCurationCarouselCardsInput: Encodable {
    public let categoryId: String
    public let mapLatitude: Double
    public let mapLongitude: Double
    public let maxDistanceM: Double?

    public init(categoryId: String, mapLatitude: Double, mapLongitude: Double, maxDistanceM: Double? = nil) {
        self.categoryId = categoryId
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
        self.maxDistanceM = maxDistanceM
    }
}
