import Foundation

import Model

enum ReviewApi {
    case fetchStoreReview(storeId: Int, input: FetchStoreReviewRequestInput)
    case reportReview(storeId: Int, reviewId: Int, input: ReportReviewRequestInput)
    case fetchMyStoreReview(input: CursorRequestInput)
    case toggleReviewSticker(storeId: Int, reviewId: Int, input: StoreReviewStickerListReplaceInput)
}

extension ReviewApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchStoreReview(_, let input):
            return input
        case .reportReview(_, _, let input):
            return input
        case .fetchMyStoreReview(let input):
            return input
        case .toggleReviewSticker(_, _, let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchStoreReview:
            return .get
        case .reportReview:
            return .post
        case .fetchMyStoreReview:
            return .get
        case .toggleReviewSticker:
            return .put
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchStoreReview:
            return .json
        case .reportReview:
            return .json
        case .fetchMyStoreReview:
            return .json
        case .toggleReviewSticker:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .fetchStoreReview(let storeId, _):
            return "/api/v4/store/\(storeId)/reviews"
        case .reportReview(let storeId, let reviewId, _):
            return "/api/v1/store/\(storeId)/review/\(reviewId)/report"
        case .fetchMyStoreReview:
            return "/api/v4/my/store-reviews"
        case .toggleReviewSticker(let storeId, let reviewId, _):
            return "/api/v1/store/\(storeId)/review/\(reviewId)/stickers"
        }
    }
}
