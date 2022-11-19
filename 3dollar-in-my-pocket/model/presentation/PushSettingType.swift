enum PushSettingType {
    case advertisement
    case unknown
    
    init(value: String) {
        switch value {
        case "ADVERTISEMENT":
            self = .advertisement
            
        default:
            self = .unknown
        }
    }
    
    var value: String {
        switch self {
        case .advertisement:
            return "ADVERTISEMENT"
            
        case .unknown:
            return ""
        }
    }
}
