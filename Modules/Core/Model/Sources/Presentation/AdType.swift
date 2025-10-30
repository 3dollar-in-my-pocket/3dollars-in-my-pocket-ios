import Foundation

public enum AdType {
    case homeCard
    case homeList
    case homeListCard
    case categoryFilter
    case community
    case pollDetail
    case storeDetail
    case frontBanner
    case searchAddress
    case pollListItem
    case localNewsFeed
    
    public var bundleKey: String {
        switch self {
        case .homeCard:
            return "ADMOB_UNIT_ID_HOME_CARD"
            
        case .homeList:
            return "ADMOB_UNIT_ID_HOME_LIST"
            
        case .homeListCard:
            return "ADMOB_UNIT_ID_HOME_LIST_CARD"
            
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
            
        case .searchAddress:
            return "ADMOB_UNIT_ID_SEARCH_ADDRESS"
            
        case .pollListItem:
            return "ADMOB_UNIT_ID_POLL_LIST_ITEM"
            
        case .localNewsFeed:
            return "ADMOB_UNIT_ID_LOCAL_NEWS_FEED"
        }
    }
}
