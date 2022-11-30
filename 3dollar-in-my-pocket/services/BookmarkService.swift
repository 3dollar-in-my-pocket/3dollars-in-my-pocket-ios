import RxSwift
import Alamofire

protocol BookmarkServiceProtocol {
    func bookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void>
    
    func unBookmarkStore(storeType: StoreType, storeId: String) -> Observable<Void>
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
}
