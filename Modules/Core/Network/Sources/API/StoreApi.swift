import Foundation
import CoreLocation

import Model

enum StoreApi {
    case fetchBossStoreDetail(FetchBossStoreDetailInput)
    case fetchStoreNewPosts(storeId: String, cursorInput: CursorRequestInput)
    case togglePostSticker(storeId: String, postId: String, input: StoreNewsPostStickersReplaceRequest)
    case fetchAroundStores(input: FetchAroundStoreInput)
    case fetchStoreDetail(input: FetchStoreDetailInput)
    case createStore(input: StoreCreateRequestInput)
    case editStore(storeId: Int, input: EditStoreRequestInput)
    case isStoresExistedAround(distance: Double, mapLocation: CLLocation)
    case saveStore(storeType: StoreType, storeId: String, isDelete: Bool)
    case reportStore(storeId: Int, reportReason: String)
    case writeReview(input: WriteReviewRequestInput)
    case fetchStorePhotos(storeId: Int, cursor: String?)
    case editReview(reviewId: Int, input: EditReviewRequestInput)
    case deletePhoto(photoId: Int)
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
        case .createStore(let input):
            return input
        case .editStore(_, let input):
            return input
        case .isStoresExistedAround(let distance, let mapLocation):
            return [
                "distance": distance,
                "mapLatitude": mapLocation.coordinate.latitude,
                "mapLongitude": mapLocation.coordinate.longitude
            ]
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
        case .isStoresExistedAround:
            return .get
        case .saveStore(_, _, let isDelete):
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
        case .createStore:
            return .json
        case .editStore:
            return .json
        case .isStoresExistedAround:
            return .json
        case .saveStore:
            return .json
        case .reportStore:
            return .json
        case .writeReview:
            return .json
        case .fetchStorePhotos:
            return .json
        case .editReview:
            return .json
        case .deletePhoto:
            return .json
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
        case .isStoresExistedAround:
            return "/api/v1/stores/near/exists"
        case .saveStore(let storeType, let storeId, _):
            return "/api/v1/favorite/subscription/store/target/\(storeType.rawValue)/\(storeId)"
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
        }
    }
}
