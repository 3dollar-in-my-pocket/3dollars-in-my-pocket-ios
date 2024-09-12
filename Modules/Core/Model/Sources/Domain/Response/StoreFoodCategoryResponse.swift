import Foundation

public struct StoreFoodCategoryResponse: Decodable, Hashable {
    public let categoryId: String
    public let name: String
    public let imageUrl: String
    public let description: String
    public let classification: StoreCategoryClassificationResponse
    public let isNew: Bool
}

public struct StoreCategoryClassificationResponse: Decodable, Hashable, Comparable {
    public static func < (lhs: StoreCategoryClassificationResponse, rhs: StoreCategoryClassificationResponse) -> Bool {
        return lhs.description < rhs.description
    }
    
    public let type: String
    public let description: String
}
