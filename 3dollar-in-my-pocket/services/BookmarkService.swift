import RxSwift
import Alamofire
import FirebaseDynamicLinks

protocol BookmarkServiceProtocol {
    func bookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void>
    
    func unBookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void>
    
    func clearBookmarks() -> Observable<Void>
    
    func fetchMyBookmarks(cursor: String?, size: Int)
    -> Observable<(cursor: Cursor, bookmarkFolder: BookmarkFolder)>
    
    func editBookmarkFolder(introduction: String, name: String) -> Observable<String>
    
    func createBookmarkURL(folderId: String) -> Observable<String>
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
    
    func clearBookmarks() -> Observable<Void> {
        let urlString = HTTPUtils.url + "/api/v1/favorite/subscription/store/clear"
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
        var parameters: [String: Any] = ["size": size]
        
        if let cursor = cursor {
            parameters["cursor"] = cursor
        }
        
        return self.networkManager.createGetObservable(
            class: UserFavoriteStoreFolderResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
        .map { (Cursor(response: $0.cursor), BookmarkFolder(response: $0)) }
    }
    
    func editBookmarkFolder(introduction: String, name: String) -> Observable<String> {
        let urlString = HTTPUtils.url + "/api/v1/favorite/FAVORITE_STORE/folder"
        let headers = HTTPUtils.defaultHeader()
        let parameters: [String: Any] = [
            "introduction": introduction,
            "name": name
        ]
        
        return self.networkManager.createPutObservable(
            class: String.self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
    }
    
    func createBookmarkURL(folderId: String) -> Observable<String> {
        return .create { observer in
            guard let link = URL(string: Bundle.bookmarkURL + "?folderId=\(folderId)") else {
                observer.onError(BaseError.custom("URL 형식이 잘못되었습니다."))
                return Disposables.create()
            }
            let dynamicLinksDomainURIPrefix = Bundle.dynamicLinkURL
            let linkBuilder = DynamicLinkComponents(
                link: link,
                domainURIPrefix: dynamicLinksDomainURIPrefix
            )
            
            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.bundleId)
            linkBuilder?.androidParameters
            = DynamicLinkAndroidParameters(packageName: "com.zion830.threedollars")
            
            linkBuilder?.shorten(completion: { url, _, _ in
                if let shortURL = url {
                    observer.onNext(shortURL.absoluteString)
                    observer.onCompleted()
                } else {
                    guard let longDynamicLink = linkBuilder?.url else {
                        return observer.onError(BaseError.custom("링크 형식이 올바르지 않습니다."))
                    }
                    
                    observer.onNext(longDynamicLink.absoluteString)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
}
