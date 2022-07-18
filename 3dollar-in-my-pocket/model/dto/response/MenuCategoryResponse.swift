import UIKit

struct MenuCategoryResponse: Decodable {
    let category: StreetFoodStoreCategory
    let description: String
    let isNew: Bool
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case category
        case description
        case isNew
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.category = try values.decodeIfPresent(
            StreetFoodStoreCategory.self,
            forKey: .category
        ) ?? .BUNGEOPPANG
        self.description = try values.decodeIfPresent(
            String.self,
            forKey: .description
        ) ?? ""
        self.isNew = try values.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}
