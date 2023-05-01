enum MarketingConsentType {
    case approve
    case deny
    case unverified
    case unknown
    
    init(value: String) {
        switch value {
        case "APPROVE":
            self = .approve
            
        case "DENY":
            self = .deny
            
        case "UNVERIFIED":
            self = .unverified
            
        default:
            self = .unknown
        }
    }
}

extension MarketingConsentType {
    var value: String {
        switch self {
        case .approve:
            return "APPROVE"
            
        case .deny:
            return "DENY"
            
        case .unverified:
            return "UNVERIFIED"
            
        case .unknown:
            return ""
        }
    }
}
