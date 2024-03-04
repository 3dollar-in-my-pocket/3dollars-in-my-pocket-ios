import Foundation

public enum AdType {
    case homeCard
    case homeList
    case categoryFilter
    case community
    case pollDetail
    case storeDetail
    case frontBanner
    
    public var bundleKey: String {
        switch self {
        case .homeCard:
            return "ADMOB_UNIT_ID_HOME_CARD"
            
        case .homeList:
            return "ADMOB_UNIT_ID_HOME_LIST"
            
        case .categoryFilter:
            return "ADMOB_UNIT_ID_CATEGORY_FILTER"
            
        case .community:
            return "ADMOB_UNIT_ID_COMMUNITY"
            
        case .pollDetail:
            return "ADMOB_UNIT_ID_POLL_DETAIL"
            
        case .storeDetail:
            return "ADMOB_UNIT_ID_STORE_DETAIL"
            
        case .frontBanner:
            return "ADMOB_UNIT_ID_FRONT_BANNER"
        }
    }
}
