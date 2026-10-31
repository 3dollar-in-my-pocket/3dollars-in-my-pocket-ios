enum DeeplinkPath: String {
    case bookmark
    case store
    case home
    case medal
    case community
    case pollDetail
    case postList
    case browser
    case accountInfo
    case reviewList
    case unknown
    case myCoupons
    case visit
    case storeImages = "store/images"
    case storeContributors = "store-contributors"
    
    init(value: String) {
        self = DeeplinkPath(rawValue: value) ?? .unknown
    }
}

extension DeeplinkPath {
    var path: String {
        rawValue
    }
}

enum StoreLandingSheet: String {
    case expanded
    case collapsed

    init(param: String?) {
        self = param.flatMap(StoreLandingSheet.init(rawValue:)) ?? .collapsed
    }
}
