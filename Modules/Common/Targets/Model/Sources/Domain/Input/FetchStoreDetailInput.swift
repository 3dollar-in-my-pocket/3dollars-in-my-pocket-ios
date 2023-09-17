import Foundation

public struct FetchStoreDetailInput: Encodable {
    // Non-encode data
    public let storeId: Int
    public let latitude: Double
    public let longitude: Double
    
    // Encode Data
    public let storeImagesCount: Int?
    public let reviewsCount: Int?
    public let visitHistoriesCount: Int?
    public let filterVisitStartDate: String?
    
    public init(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        storeImagesCount: Int? = nil,
        reviewsCount: Int? = nil,
        visitHistoriesCount: Int? = nil,
        filterVisitStartDate: String? = nil
    ) {
        self.storeId = storeId
        self.latitude = latitude
        self.longitude = longitude
        self.storeImagesCount = storeImagesCount
        self.reviewsCount = reviewsCount
        self.visitHistoriesCount = visitHistoriesCount
        self.filterVisitStartDate = filterVisitStartDate
    }
    
    enum CodingKeys: CodingKey {
        case storeImagesCount
        case reviewsCount
        case visitHistoriesCount
        case filterVisitStartDate
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(storeImagesCount, forKey: .storeImagesCount)
        try container.encodeIfPresent(reviewsCount, forKey: .reviewsCount)
        try container.encodeIfPresent(visitHistoriesCount, forKey: .visitHistoriesCount)
        try container.encodeIfPresent(filterVisitStartDate, forKey: .filterVisitStartDate)
    }
}
