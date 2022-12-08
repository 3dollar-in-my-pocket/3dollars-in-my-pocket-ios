struct BookmarkFolder {
    let bookmarks: [StoreProtocol]
    let folderId: String?
    let introduction: String
    let name: String
    let user: User
    
    init(response: UserFavoriteStoreFolderResponse) {
        self.bookmarks = 
        self.folderId = response.folderId
        self.introduction = response.introduction
        self.name = response.name
        self.user = User(response: response.user)
    }
}
