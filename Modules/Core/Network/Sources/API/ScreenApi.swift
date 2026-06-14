import Foundation

import Model

enum ScreenApi {
    case fetchHomeFilterScreen
    case fetchHomeSectionList(input: FetchHomeSectionListInput)
}

extension ScreenApi: RequestType {
    var param: (any Encodable)? {
        switch self {
        case .fetchHomeFilterScreen:
            return nil
        case .fetchHomeSectionList(let input):
            return input
        }
    }

    var method: RequestMethod {
        switch self {
        case .fetchHomeFilterScreen:
            return .get
        case .fetchHomeSectionList:
            return .get
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .fetchHomeFilterScreen:
            return .json
        case .fetchHomeSectionList:
            return .location
        }
    }

    var path: String {
        switch self {
        case .fetchHomeFilterScreen:
            return "/api/v1/screen/home"
        case .fetchHomeSectionList:
            return "/api/v1/screen/home/section/list"
        }
    }
}
