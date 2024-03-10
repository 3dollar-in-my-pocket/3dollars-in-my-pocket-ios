import Foundation

import Model

public protocol BookmarkServiceProtocol {
    func fetchBookmarkStore(input: FetchBookmarkStoreRequestInput) async -> Result<StoreFavoriteFolderApiResponse, Error>
    
    func removeBookmarkStore(storeId: Int) async -> Result<String, Error>
    
    func removeAllBookmarkStore() async -> Result<String, Error>
    
    func editBookmarkFolder(input: EditBookmarkFolderInput) async -> Result<String, Error>
    
    func fetchBookmarkFolder(folderId: String, size: Int, cursor: String?) async -> Result<StoreFavoriteFolderApiResponse, Error>
}

public struct BookmarkService: BookmarkServiceProtocol {
    public init() { }
    
    public func fetchBookmarkStore(input: FetchBookmarkStoreRequestInput) async -> Result<StoreFavoriteFolderApiResponse, Error> {
        let request = FetchBookmarkStoreRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func removeBookmarkStore(storeId: Int) async -> Result<String, Error> {
        let request = RemoveBookmarkStoreRequest(storeId: storeId)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func removeAllBookmarkStore() async -> Result<String, Error> {
        let request = RemoveAllBookmarkStoreRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editBookmarkFolder(input: EditBookmarkFolderInput) async -> Result<String, Error> {
        let request = EditBookmarkFolderRequest(input: input, folderType: .favoriteStore)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchBookmarkFolder(folderId: String, size: Int, cursor: String?) async -> Result<StoreFavoriteFolderApiResponse, Error> {
        let request = FetchBookmarkFolderRequest(folderId: folderId, size: size, cursor: cursor)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
