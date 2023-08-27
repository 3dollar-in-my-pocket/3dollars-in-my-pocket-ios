import Foundation

import Networking

public struct PlatformStoreCategory {
    let category: String
    let categoryId: String
    let name: String
    let imageUrl: String
    let disableImageUrl: String
    let description: String
    let classification: PlatformStoreCategoryClassification
    let isNew: Bool
    
    
    public init(response: PlatformStoreCategoryResponse) {
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
    public func hash(into hasher: inout Hasher) {
        hasher.combine(categoryId)
    }
}


public struct PlatformStoreCategoryClassification: Hashable, Comparable {
    public static func < (lhs: PlatformStoreCategoryClassification, rhs: PlatformStoreCategoryClassification) -> Bool {
        return lhs.description < rhs.description
    }
    
    public enum ClassificationType: String {
        case meal = "MEAL"
        case snack = "SNACK"
        
        init(value: String) {
            self = ClassificationType(rawValue: value) ?? .snack
        }
    }
    
    public let type: ClassificationType
    public let description: String
    
    public init(response: PlatformStoreCategoryClassificationResponse) {
        self.type = ClassificationType(value: response.type)
        self.description = response.description
    }
}
