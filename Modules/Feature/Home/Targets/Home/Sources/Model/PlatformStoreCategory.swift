import Foundation

import Networking

struct PlatformStoreCategory {
    let category: String
    let categoryId: String
    let name: String
    let imageUrl: String
    let disableImageUrl: String
    let description: String
    let classification: PlatformStoreCategoryClassification
    let isNew: Bool
    
    
    init(response: PlatformStoreCategoryResponse) {
        self.category = response.category
        self.categoryId = response.categoryId
        self.name = response.name
        self.imageUrl = response.imageUrl
        self.disableImageUrl = response.disableImageUrl
        self.description = response.description
        self.classification = PlatformStoreCategoryClassification(response: response.classification)
        self.isNew = response.isNew
    }
}

extension PlatformStoreCategory: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(categoryId)
    }
}


struct PlatformStoreCategoryClassification: Hashable, Comparable {
    static func < (lhs: PlatformStoreCategoryClassification, rhs: PlatformStoreCategoryClassification) -> Bool {
        return lhs.description < rhs.description
    }
    
    enum ClassificationType: String {
        case meal = "MEAL"
        case snack = "SNACK"
        
        init(value: String) {
            self = ClassificationType(rawValue: value) ?? .snack
        }
    }
    
    let type: ClassificationType
    let description: String
    
    init(response: PlatformStoreCategoryClassificationResponse) {
        self.type = ClassificationType(value: response.type)
        self.description = response.description
    }
}
