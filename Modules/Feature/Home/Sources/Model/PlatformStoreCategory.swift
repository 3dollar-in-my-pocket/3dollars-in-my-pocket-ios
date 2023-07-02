import Foundation

import Networking

struct PlatformStoreCategory {
    let category: String
    let categoryId: String
    let name: String
    let imageUrl: String
    let disableImageUrl: String
    let description: String
    let classificationType: String
    let isNew: Bool
    
    
    init(response: PlatformStoreCategoryResponse) {
        self.category = response.category
        self.categoryId = response.categoryId
        self.name = response.name
        self.imageUrl = response.imageUrl
        self.disableImageUrl = response.disableImageUrl
        self.description = response.description
        self.classificationType = response.classificationType
        self.isNew = response.isNew
    }
}
