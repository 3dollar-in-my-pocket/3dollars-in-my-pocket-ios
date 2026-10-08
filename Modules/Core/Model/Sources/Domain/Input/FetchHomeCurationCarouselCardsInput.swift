import Foundation

public struct FetchHomeCurationCarouselCardsInput: Encodable {
    public let categoryId: String
    public let mapLatitude: Double
    public let mapLongitude: Double

    public init(categoryId: String, mapLatitude: Double, mapLongitude: Double) {
        self.categoryId = categoryId
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
    }
}
