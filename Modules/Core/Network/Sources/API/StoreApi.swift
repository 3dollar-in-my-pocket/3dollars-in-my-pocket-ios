import Foundation
import CoreLocation

import Model

enum StoreApi {
    case fetchBossStoreDetail(FetchBossStoreDetailInput)
    case fetchStoreNewPosts(storeId: String, cursorInput: CursorRequestInput)
    case togglePostSticker(storeId: String, postId: String, input: StoreNewsPostStickersReplaceRequest)
    case fetchAroundStores(input: FetchAroundStoreInput)
    case fetchStoreDetail(input: FetchStoreDetailInput)
    case createStore(input: UserStoreCreateRequest, nonceToken: String)
    case editStore(storeId: Int, input: EditStoreRequestInput)
    case saveStore(storeId: String, isDelete: Bool)
    case reportStore(storeId: Int, reportReason: String)
    case writeReview(input: WriteReviewRequestInput)
    case fetchStorePhotos(storeId: Int, cursor: String?)
    case editReview(reviewId: Int, input: EditReviewRequestInput)
    case deletePhoto(photoId: Int)
    case existsFeedbackOnDateByAccount(storeId: Int)
    case fetchStore(input: FetchStoreInput)
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
        case .fetchAroundStores(let input):
            return input
        case .fetchStoreDetail(let input):
            return input
        case .createStore(let input, _):
            return input
        case .editStore(_, let input):
            return input
        case .saveStore:
            return nil
        case .reportStore(_, let reportReason):
            return ["deleteReasonType": reportReason]
        case .writeReview(let input):
            return input
        case .fetchStorePhotos(let storeId, let cursor):
            var params = ["storeId": "\(storeId)"]
            
            if let cursor {
                params["cursor"] = cursor
            }
            
            return params
        case .editReview(_, let input):
            return input
        case .deletePhoto:
            return nil
        case .existsFeedbackOnDateByAccount:
            return nil
        case .fetchStore(let input):
            return ["includes": input.includes]
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
        case .fetchAroundStores:
            return .get
        case .fetchStoreDetail:
            return .get
        case .createStore:
            return .post
        case .editStore:
            return .put
        case .saveStore(_, let isDelete):
            return isDelete ? .delete : .put
        case .reportStore:
            return .delete
        case .writeReview:
            return .post
        case .fetchStorePhotos:
            return .get
        case .editReview:
            return .put
        case .deletePhoto:
            return .delete
        case .existsFeedbackOnDateByAccount:
            return .get
        case .fetchStore:
            return .get
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
            return .json
        case .togglePostSticker:
            return .json
        case .fetchAroundStores:
            return .location
        case .fetchStoreDetail:
            return .location
        case .createStore(_, let token):
            return .custom(["X-Nonce-Token": token])
        case .editStore:
            return .json
        case .saveStore:
            return .json
        case .reportStore:
            return .json
        case .writeReview(let input):
            return .custom(["X-Nonce-Token": input.nonceToken])
        case .fetchStorePhotos:
            return .json
        case .editReview(_, let input):
            return .custom(["X-Nonce-Token": input.nonceToken])
        case .deletePhoto:
            return .json
        case .existsFeedbackOnDateByAccount:
            return .json
        case .fetchStore:
            return .location
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
        case .fetchAroundStores:
            return "/api/v4/stores/around"
        case .fetchStoreDetail(let input):
            return "/api/v4/store/\(input.storeId)"
        case .createStore:
            return "/api/v2/store"
        case .editStore(let storeId, _):
            return "/api/v2/store/\(storeId)"
        case .saveStore(let storeId, _):
            return "/api/v2/store/\(storeId)/favorite"
        case .reportStore(let storeId, _):
            return "/api/v2/store/\(storeId)"
        case .writeReview:
            return "/api/v3/store/review"
        case .fetchStorePhotos(let storeId, _):
            return "/api/v4/store/\(storeId)/images"
        case .editReview(let reviewId, _):
            return "/api/v2/store/review/\(reviewId)"
        case .deletePhoto(let photoId):
            return "/api/v2/store/image/\(photoId)"
        case .existsFeedbackOnDateByAccount(let storeId):
            return "/api/v1/feedback/STORE/target/\(storeId)/exists"
        case .fetchStore(let input):
            return "/api/v5/store/\(input.storeId)"
        }
    }
}
