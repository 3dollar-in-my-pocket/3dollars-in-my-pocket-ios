public enum SocialType: String, Decodable {
    case kakao = "KAKAO"
    case apple = "APPLE"
    case google = "GOOGLE"
    case unknown
    
    public init(value: String) {
        self = SocialType(rawValue: value) ?? .unknown
    }
    
    public init(from decoder: Decoder) throws {
        self = try SocialType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
