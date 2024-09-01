public struct PlatformStoreCategoryResponse: Decodable {
    public let category: String
    public let categoryId: String
    public let name: String
    public let imageUrl: String
    public let disableImageUrl: String
    public let description: String
    public let classification: StoreCategoryClassificationResponse
    public let isNew: Bool
}

extension PlatformStoreCategoryResponse: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(categoryId)
    }
    
    public static func == (lhs: PlatformStoreCategoryResponse, rhs: PlatformStoreCategoryResponse) -> Bool {
        return lhs.categoryId == rhs.categoryId
    }
}
