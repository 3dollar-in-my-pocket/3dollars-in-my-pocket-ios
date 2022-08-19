import UIKit

struct MenuCategoryResponse: Decodable {
    let categoryId: String
    let category: String
    let description: String
    let imageUrl: String
    let isNew: Bool
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId
        case category
        case description
        case imageUrl
        case isNew
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.categoryId = try values.decodeIfPresent(String.self, forKey: .categoryId) ?? ""
        self.category = try values.decodeIfPresent(String.self, forKey: .category) ?? ""
        self.description = try values.decodeIfPresent(
            String.self,
            forKey: .description
        ) ?? ""
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.isNew = try values.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}
