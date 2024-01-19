public enum MarketingConsent: String, Codable {
    case approve = "APPROVE"
    case deny = "DENY"
    case unverified = "UNVERIFIED"
    case unknown
    
    public init(value: String) {
        self = MarketingConsent(rawValue: value) ?? .unverified
    }
    
    public init(from decoder: Decoder) throws {
        self = try MarketingConsent(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
