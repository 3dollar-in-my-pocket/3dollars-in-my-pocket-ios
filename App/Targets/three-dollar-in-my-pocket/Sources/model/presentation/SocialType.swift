enum SocialType: String {
    case kakao = "KAKAO"
    case apple = "APPLE"
    case google = "GOOGLE"
    case unknown
    
    init(value: String) {
        self = SocialType(rawValue: value) ?? .unknown
    }
}

extension SocialType {
    var value: String {
        self.rawValue
    }
}
