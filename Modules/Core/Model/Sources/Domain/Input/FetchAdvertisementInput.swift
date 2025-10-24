import Foundation

public struct FetchAdvertisementInput: Encodable {
    public let position: AdvertisementPosition
    public let size: Int?
    public let platform: String
    
    public init(position: AdvertisementPosition, size: Int? = nil, platform: String = "IOS") {
        self.position = position
        self.size = size
        self.platform = platform
    }
}

public enum AdvertisementPosition: String, Encodable {
    case loading = "LOADING"
    case menuCategoryBanner = "MENU_CATEGORY_BANNER"
    case menuCategoryIcon = "MENU_CATEGORY_ICON"
    case splash = "SPLASH"
    case storeCategoryList = "STORE_CATEGORY_LIST"
    case storeMarker = "STORE_MARKER"
    case storeMarkerPopup = "STORE_MARKER_POPUP"
    case pollCard = "POLL_CARD"
    case storeList = "STORE_LIST"
    case localNewsFeed = "LOCAL_NEWS_FEED"
}
