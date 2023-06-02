public struct PlatformStoreCategoryResponse: Decodable {
    public let category: String
    public let categoryId: String
    public let name: String
    public let imageUrl: String
    public let description: String
    public let classificationType: String
    public let isNew: Bool
}
