public enum MarketingConsent: String {
    case approve = "APPROVE"
    case deny = "DENY"
    case unverified = "UNVERIFIED"
    
    public init(value: String) {
        self = MarketingConsent(rawValue: value) ?? .unverified
    }
}
