enum DeeplinkType: String {
    case bookmark
    case store
    case home
    case medal
    case community
    case unknown
    
    init(value: String) {
        self = DeeplinkType(rawValue: value) ?? .unknown
    }
}

extension DeeplinkType {
    var path: String {
        rawValue
    }
}
