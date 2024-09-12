import Foundation

public struct FetchAroundStoreInput: Encodable {
    public let distanceM: Double
    public let categoryIds: [String]?
    public let targetStores: [StoreType]?
    public let sortType: StoreSortType
    public let filterCertifiedStores: Bool?
    public let filterConditions: [ActivitiesStatus]?
    public let size: Int
    public let cursor: String?
    public let mapLatitude: Double
    public let mapLongitude: Double
    
    public init(
        distanceM: Double,
        categoryIds: [String]? = nil,
        targetStores: [StoreType] = [.userStore, .bossStore],
        sortType: StoreSortType = .distanceAsc,
        filterCertifiedStores: Bool? = false,
        filterConditions: [ActivitiesStatus]? = nil,
        size: Int = 10,
        cursor: String? = nil,
        mapLatitude: Double,
        mapLongitude: Double
    ) {
        self.distanceM = distanceM
        self.categoryIds = categoryIds
        self.targetStores = targetStores
        self.sortType = sortType
        self.filterCertifiedStores = filterCertifiedStores
        self.filterConditions = filterConditions
        self.size = size
        self.cursor = cursor
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
    }
}
