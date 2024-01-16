public struct StoreFavoriteFolderApiResponse: Decodable {
    public let folderId: String?
    public let isOwner: Bool
    public let name: String
    public let introduction: String
    public let user: UserApiResponse
    public let favorites: [PlatformStoreResponse]
    public let cursor: CursorWithTotalCountResponse
}
