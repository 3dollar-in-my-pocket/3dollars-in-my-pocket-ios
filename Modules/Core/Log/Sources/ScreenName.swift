import Foundation

public enum ScreenName: String {
    case empty
    
    case markerPopup = "marker_popup"
    
    // Membership
    case signIn = "sign_in"
    case signUp = "sign_up"
    
    // Home
    case home
    case homeList = "home_list"
    case categoryFilter = "category_filter"
    case mainBannerPopup = "main_banner_popup"
    
    /// Write
    case writeAddress = "write_address"
    case writeAddressPopup = "write_address_popop"
    case writeAddressDetail = "write_address_detail"
    
    case categorySelection = "category_selection"
    
    /// Store
    case storeDetail = "store_detail"
    case uploadPhoto = "upload_photo"
    case reviewList = "review_list"
    case reportStore = "report_store"
    case reviewBottomSheet = "review_bottom_sheet"
    case visitStore = "visit_store"
    case bossStoreDetail = "boss_store_detail"
    case bossStoreReview = "boss_store_review"
    
    /// Community
    case community = "community"
    case pollDetail = "poll_detail"
    case pollList = "poll_list"
    case reportPoll = "report_poll"
    case reportReview = "report_review"
    case createPoll = "careate_poll"
}
