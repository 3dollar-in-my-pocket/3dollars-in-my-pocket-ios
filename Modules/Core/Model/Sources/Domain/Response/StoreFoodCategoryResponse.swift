import Foundation

public struct StoreFoodCategoryResponse: Decodable {
    public let categoryId: String
    public let name: String
    public let imageUrl: String
    public let description: String
    public let classification: StoreCategoryClassificationResponse
    public let isNew: Bool
}
