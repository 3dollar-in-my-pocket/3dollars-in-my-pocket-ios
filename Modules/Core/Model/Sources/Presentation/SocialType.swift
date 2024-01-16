public enum SocialType: String {
    case kakao = "KAKAO"
    case apple = "APPLE"
    case google = "GOOGLE"
    case unknown
    
    public init(value: String) {
        self = SocialType(rawValue: value) ?? .unknown
    }
}
