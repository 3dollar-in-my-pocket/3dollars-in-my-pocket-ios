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
    case unknown
    
    init(value: String) {
        self = DeeplinkPath(rawValue: value) ?? .unknown
    }
}

extension DeeplinkPath {
    var path: String {
        rawValue
    }
}
