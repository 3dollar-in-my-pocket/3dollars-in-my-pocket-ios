import UIKit

struct PlatformStoreCategoryResponse: Decodable {
    let categoryId: String
    let category: String
    let description: String
    let imageUrl: String
    let isNew: Bool
    let name: String
}
