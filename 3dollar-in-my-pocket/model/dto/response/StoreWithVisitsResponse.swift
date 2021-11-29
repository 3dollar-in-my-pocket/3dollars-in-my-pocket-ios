import Foundation

struct StoreWithVisitsResponse: Decodable {
    
    let categories: [StoreCategory]
    let createdAt: String
    let isDeleted: Bool
    let latitude: Double
    let longitude: Double
    let rating: Double
    let storeId: Int
    let storeName: String
    let updatedAt: String
    let visitHistory: VisitHistoryCountsResponse
    
    enum CodingKeys: String, CodingKey {
        case categories
        case createdAt
        case isDeleted
        case latitude
        case longitude
        case rating
        case storeId
        case storeName
        case updatedAt
        case visitHistory
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.categories = try values.decodeIfPresent([StoreCategory].self, forKey: .categories) ?? []
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.isDeleted = try values.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        self.longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        self.rating = try values.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? 0
        self.storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
        self.visitHistory = try values.decodeIfPresent(
            VisitHistoryCountsResponse.self,
            forKey: .visitHistory
        ) ?? VisitHistoryCountsResponse()
    }
}
