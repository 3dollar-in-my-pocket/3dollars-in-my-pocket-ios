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

struct FetchPopularStoreNeighborhoodsRequest: RequestType {
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

struct FetchPollReportReasonRequest: RequestType {
    var param: Encodable? {
        return nil
    }

    var method: RequestMethod {
        return .get
    }

    var path: String {
        return "/api/v1/report/group/POLL/reasons"
    }
}

struct PollReportCreateRequest: RequestType {
    let pollId: String
    let requestInput: PollReportCreateRequestInput

    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .post
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v1/poll/\(pollId)/report"
    }
}

struct FetchPollsRequest: RequestType {
    let requestInput: FetchPollsRequestInput

    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v1/polls"
    }
}
