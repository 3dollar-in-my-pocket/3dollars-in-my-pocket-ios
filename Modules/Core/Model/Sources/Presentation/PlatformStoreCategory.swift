import Foundation

public struct PlatformStoreCategory {
    public let category: String
    public let categoryId: String
    public let name: String
    public let imageUrl: String
    public let disableImageUrl: String
    public let description: String
    public let classification: PlatformStoreCategoryClassification
    public let isNew: Bool
    
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
    
    public init(response: PlatformStoreFoodCategoryResponse) {
        self.category = ""
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
