public struct StoreFavoriteFolderApiResponse: Decodable {
    public let folderId: String?
    public let isOwner: Bool
    public let name: String
    public let introduction: String
    public let user: UserResponse
    public let favorites: [StoreResponse]
    public let cursor: CursorAndTotalCountString
}
