import Foundation

public struct FetchAdvertisementInput: Encodable {
    public let position: AdvertisementPosition
    public let size: Int?
    public let platform = "IOS"
    
    public init(position: AdvertisementPosition, size: Int?) {
        self.position = position
        self.size = size
    }
}

public enum AdvertisementPosition: String, Encodable {
    case mainPageCard = "MAIN_PAGE_CARD"
    case menuCategoryBanner = "MENU_CATEGORY_BANNER"
    case splash = "SPLASH"
    case storeCategoryList = "STORE_CATEGORY_LIST"
    case storeMarker = "STORE_MARKER"
    case storeMarkerPopup = "STORE_MARKER_POPUP"
    case pollCard = "POLL_CARD"
}
