import Foundation

public struct PlatformStoreFoodCategoryResponse: Decodable {
    public let categoryId: String
    public let name: String
    public let imageUrl: String
    public let disableImageUrl: String
    public let description: String
    public let classification: PlatformStoreCategoryClassificationResponse
    public let isNew: Bool
}
