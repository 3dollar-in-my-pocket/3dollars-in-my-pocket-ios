public enum MarketingConsent: String, Decodable {
    case approve = "APPROVE"
    case deny = "DENY"
    case unverified = "UNVERIFIED"
    
    public init(from decoder: Decoder) throws {
        self = try MarketingConsent(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unverified
    }
}
