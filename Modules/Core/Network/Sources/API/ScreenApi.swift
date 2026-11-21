import Foundation

import Model

enum ScreenApi {
    case fetchHomeFilterScreen(input: FetchHomeFilterScreenInput)
    case fetchHomeSectionList(input: FetchHomeSectionListInput)
    case fetchHomeCurationSection(curationTabId: String, input: FetchHomeCurationSectionInput)
    case fetchHomeCurationCarouselCards(
        curationTabId: String,
        carouselId: String,
        input: FetchHomeCurationCarouselCardsInput
    )
    case fetchHomeNewsSection(newsTabId: String)
}

extension ScreenApi: RequestType {
    var param: (any Encodable)? {
        switch self {
        case .fetchHomeFilterScreen(let input):
            return input
        case .fetchHomeSectionList(let input):
            return input
        case .fetchHomeCurationSection(_, let input):
            return input
        case .fetchHomeCurationCarouselCards(_, _, let input):
            return input
        case .fetchHomeNewsSection:
            return nil
        }
    }

    var method: RequestMethod {
        switch self {
        case .fetchHomeFilterScreen:
            return .get
        case .fetchHomeSectionList:
            return .get
        case .fetchHomeCurationSection:
            return .get
        case .fetchHomeCurationCarouselCards:
            return .get
        case .fetchHomeNewsSection:
            return .get
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .fetchHomeFilterScreen:
            return .json
        case .fetchHomeSectionList:
            return .location
        case .fetchHomeCurationSection:
            return .location
        case .fetchHomeCurationCarouselCards:
            return .location
        case .fetchHomeNewsSection:
            return .json
        }
    }

    var path: String {
        switch self {
        case .fetchHomeFilterScreen:
            return "/api/v1/screen/home"
        case .fetchHomeSectionList:
            return "/api/v1/screen/home/section/list"
        case .fetchHomeCurationSection(let curationTabId, _):
            return "/api/v1/screen/home/section/curation/\(curationTabId)"
        case .fetchHomeCurationCarouselCards(let curationTabId, let carouselId, _):
            return "/api/v1/screen/home/section/curation/\(curationTabId)/carousel/\(carouselId)/cards"
        case .fetchHomeNewsSection(let newsTabId):
            return "/api/v1/screen/home/section/news/\(newsTabId)"
        }
    }
}
