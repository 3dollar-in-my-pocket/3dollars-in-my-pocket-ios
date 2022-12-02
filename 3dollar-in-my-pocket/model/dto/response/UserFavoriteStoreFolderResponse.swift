struct UserFavoriteStoreFolderResponse: Decodable {
    let cursor: CursorWithTotalCountResponse
    let favorites: [PlatformStoreResponse]
    let folderId: String?
    let introduction: String
    let name: String
    let user: UserPublicInfoResponse
}
