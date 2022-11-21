enum PushPlatformType {
    case fcm
    case unknown
    
    init(value: String) {
        switch value {
        case "FCM":
            self = .fcm
            
        default:
            self = .unknown
        }
    }
    
    var value: String {
        switch self {
        case .fcm:
            return "FCM"
            
        case .unknown:
            return ""
        }
    }
}
