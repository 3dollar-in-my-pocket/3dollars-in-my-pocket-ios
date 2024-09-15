import Foundation

public struct FetchStoreDetailInput: Encodable {
    // Non-encode data
    public let storeId: Int
    
    // Encode Data
    public let storeImagesCount: Int?
    public let reviewsCount: Int?
    public let visitHistoriesCount: Int?
    
    public init(
        storeId: Int,
        storeImagesCount: Int? = nil,
        reviewsCount: Int? = nil,
        visitHistoriesCount: Int? = nil
    ) {
        self.storeId = storeId
        self.storeImagesCount = storeImagesCount
        self.reviewsCount = reviewsCount
        self.visitHistoriesCount = visitHistoriesCount
    }
    
    enum CodingKeys: String, CodingKey {
        case storeImagesCount
        case reviewsCount
        case visitHistoriesCount
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(storeImagesCount, forKey: .storeImagesCount)
        try container.encodeIfPresent(reviewsCount, forKey: .reviewsCount)
        try container.encodeIfPresent(visitHistoriesCount, forKey: .visitHistoriesCount)
    }
}
