/*
 커뮤니티 탭에서 사용하는 Request 목록
 추후 파일 분리 필요합니다.
 */

import Foundation

import Model

struct FetchPopularStoresRequest: RequestType {
    let requestInput: FetchPopularStoresInput

    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var path: String {
        return "/api/v1/neighborhood/popular-stores"
    }
}

struct FetchPopularStoreNeighborhoods: RequestType {
    var param: Encodable? {
        return nil
    }

    var method: RequestMethod {
        return .get
    }

    var path: String {
        return "/api/v1/neighborhood/popular-store/neighborhoods"
    }
}

