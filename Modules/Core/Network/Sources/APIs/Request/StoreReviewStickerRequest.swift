import Foundation

import Model

struct StoreReviewStickerListRequest: RequestType {
    let input: StoreReviewStickerListReplaceInput
    let storeId: Int
    let reviewId: Int
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .put
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/store/\(storeId)/review/\(reviewId)/stickers"
    }
}
