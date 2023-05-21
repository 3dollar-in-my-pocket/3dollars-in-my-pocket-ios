import Foundation

struct VisitHistoryWithStoreResponse: Decodable {
    
    let createdAt: String
    let dateOfVisit: String
    let store: StoreInfoResponse
    let type: VisitType
    let visitHistoryId: Int
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case dateOfVisit
        case store
        case type
        case visitHistoryId
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.dateOfVisit = try values.decodeIfPresent(String.self, forKey: .dateOfVisit) ?? ""
        self.store = try values.decodeIfPresent(
            StoreInfoResponse.self,
            forKey: .store
        ) ?? StoreInfoResponse()
        self.type = try values.decodeIfPresent(VisitType.self, forKey: .type) ?? .notExists
        self.visitHistoryId = try values.decodeIfPresent(Int.self, forKey: .visitHistoryId) ?? 0
    }
}
