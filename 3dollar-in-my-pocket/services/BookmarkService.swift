import RxSwift
import Alamofire

protocol BookmarkServiceProtocol {
    func bookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void>
    
    func unBookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void>
    
    func fetchMyBookmarks(cursor: String?, size: Int)
    -> Observable<(cursor: Cursor, bookmarkFolder: BookmarkFolder)>
}

struct BookmarkService: BookmarkServiceProtocol {
    private let networkManager = NetworkManager()
    
    func bookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void> {
        let urlString = HTTPUtils.url
        + "/api/v1/favorite/subscription/store/target/\(storeType.targetType)/\(storeId)"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createPutObservable(
            class: String.self,
            urlString: urlString,
            headers: headers
        )
        .map { _ in () }
    }
    
    func unBookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void> {
        let urlString = HTTPUtils.url
        + "/api/v1/favorite/subscription/store/target/\(storeType.targetType)/\(storeId)"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createDeleteObservable(
            urlString: urlString,
            headers: headers
        )
    }
    
    func fetchMyBookmarks(cursor: String?, size: Int)
    -> Observable<(cursor: Cursor, bookmarkFolder: BookmarkFolder)> {
        let urlString = HTTPUtils.url + "/api/v1/favorite/store/folder/my"
        let headers = HTTPUtils.defaultHeader()
        let parameters: [String: Any] = ["cursor": cursor as Any, "size": size]
        
        return self.networkManager.createGetObservable(
            class: UserFavoriteStoreFolderResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
        .map { (Cursor(response: $0.cursor), BookmarkFolder(response: $0)) }
    }
}
