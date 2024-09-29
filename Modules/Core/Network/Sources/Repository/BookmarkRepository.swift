import Foundation

import Model

public protocol BookmarkRepository {
    func fetchBookmarkStore(input: FetchBookmarkStoreRequestInput) async -> Result<StoreFavoriteFolderApiResponse, Error>
    
    func removeBookmarkStore(storeId: Int) async -> Result<String, Error>
    
    func removeAllBookmarkStore() async -> Result<String, Error>
    
    func editBookmarkFolder(input: EditBookmarkFolderInput) async -> Result<String, Error>
    
    func fetchBookmarkFolder(folderId: String, input: FetchBookmarkFolderInput) async -> Result<StoreFavoriteFolderApiResponse, Error>
}

public struct BookmarkRepositoryImpl: BookmarkRepository {
    public init() { }
    
    public func fetchBookmarkStore(input: FetchBookmarkStoreRequestInput) async -> Result<StoreFavoriteFolderApiResponse, Error> {
        let request = BookmarkApi.fetchBookmarkStore(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func removeBookmarkStore(storeId: Int) async -> Result<String, Error> {
        let request = BookmarkApi.removeBookmarkStore(storeId: storeId)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func removeAllBookmarkStore() async -> Result<String, Error> {
        let request = BookmarkApi.removeAllBookmarkStore
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editBookmarkFolder(input: EditBookmarkFolderInput) async -> Result<String, Error> {
        let request = BookmarkApi.editBookmarkFolder(folderType: .favoriteStore, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchBookmarkFolder(folderId: String, input: FetchBookmarkFolderInput) async -> Result<StoreFavoriteFolderApiResponse, Error> {
        let request = BookmarkApi.fetchBookmarkFolder(folderId: folderId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
