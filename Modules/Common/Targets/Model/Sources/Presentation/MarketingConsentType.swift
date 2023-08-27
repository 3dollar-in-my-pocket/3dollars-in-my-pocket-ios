public enum MarketingConsentType: String {
    case approve = "APPROVE"
    case deny = "DENY"
    case unverified = "UNVERIFIED"
    case unknown
    
    public init(value: String) {
        self = MarketingConsentType(rawValue: value) ?? .unknown
    }
}
