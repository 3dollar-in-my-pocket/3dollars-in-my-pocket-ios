import Foundation

public struct FetchAroundStoreInput: Encodable {
    public let distanceM: Double?
    public let categoryIds: [String]?
    public let targetStores: [String]
    public let sortType: String? // DISTANCE_ASC, LATEST
    public let filterCertifiedStores: Bool?
    public let size: Int?
    public let cursor: String?
    public let mapLatitude: Double
    public let mapLongitude: Double
    
    public init(
        distanceM: Double?,
        categoryIds: [String]?,
        targetStores: [String],
        sortType: String?,
        filterCertifiedStores: Bool?,
        size: Int?,
        cursor: String?,
        mapLatitude: Double,
        mapLongitude: Double
    ) {
        self.distanceM = distanceM
        self.categoryIds = categoryIds
        self.targetStores = targetStores
        self.sortType = sortType
        self.filterCertifiedStores = filterCertifiedStores
        self.size = size
        self.cursor = cursor
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
    }
}