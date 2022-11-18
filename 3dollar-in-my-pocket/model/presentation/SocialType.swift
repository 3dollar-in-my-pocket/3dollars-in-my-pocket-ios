enum SocialType {
    case kakao
    case apple
    case google
    case unknown
    
    init(value: String) {
        switch value {
        case "KAKAO":
            self = .kakao
            
        case "APPLE":
            self = .apple
            
        case "GOOGLE":
            self = .google
            
        default:
            self = .unknown
        }
    }
    
}

extension SocialType {
    var value: String {
        switch self {
        case .kakao:
            return "KAKAO"
            
        case .apple:
            return "APPLE"
            
        case .google:
            return "GOOGLE"
            
        case .unknown:
            return ""
        }
    }
}
