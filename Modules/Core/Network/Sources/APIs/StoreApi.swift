import Foundation

import Model

enum StoreApi {
    case fetchBossStoreDetail(FetchBossStoreDetailInput)
    case fetchStoreNewPosts(storeId: String, cursorInput: CursorRequestInput)
    case togglePostSticker(storeId: String, postId: String, input: StoreNewsPostStickersReplaceRequest)
}

extension StoreApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchBossStoreDetail:
            return nil
        case .fetchStoreNewPosts(_, let cursorInput):
            return cursorInput
        case .togglePostSticker(_, _, let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchBossStoreDetail:
            return .get
        case .fetchStoreNewPosts:
            return .get
        case .togglePostSticker:
            return .put
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchBossStoreDetail(let input):
            return .custom([
                "X-Device-Latitude": String(input.latitude),
                "X-Device-Longitude": String(input.longitude)
            ])
        case .fetchStoreNewPosts:
            return .auth
        case .togglePostSticker:
            return .auth
        }
    }
    
    var path: String {
        switch self {
        case .fetchBossStoreDetail(let input):
            return "/api/v4/boss-store/\(input.storeId)"
        case .fetchStoreNewPosts(let storeId, _):
            return "/api/v1/store/\(storeId)/news-posts"
        case .togglePostSticker(let storeId, let postId, _):
            return "/api/v1/store/\(storeId)/news-post/\(postId)/stickers"
        }
    }
}
