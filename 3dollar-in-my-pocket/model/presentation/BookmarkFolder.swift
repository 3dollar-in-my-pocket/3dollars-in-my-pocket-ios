struct BookmarkFolder {
    var bookmarks: [StoreProtocol]
    let folderId: String?
    let introduction: String
    let name: String
    let user: User
    
    init(
        bookmarks: [StoreProtocol] = [],
        folderId: String? = nil,
        introduction: String = "",
        name: String = "",
        user: User = User()
    ) {
        self.bookmarks = bookmarks
        self.folderId = folderId
        self.introduction = introduction
        self.name = name
        self.user = user
    }
    
    init(response: UserFavoriteStoreFolderResponse) {
        self.bookmarks = response.favorites.map(PlatformStore.init(response:))
        self.folderId = response.folderId
        self.introduction = response.introduction
        self.name = response.name
        self.user = User(response: response.user)
    }
}
