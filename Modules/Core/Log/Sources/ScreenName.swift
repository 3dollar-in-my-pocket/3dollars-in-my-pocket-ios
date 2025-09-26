import Foundation

public enum ScreenName: String {
    case empty
    
    case splash
    
    case markerPopup = "marker_popup"
    
    // Membership
    case signIn = "sign_in"
    case signUp = "sign_up"
    case accountInfo = "account_info"
    
    // Home
    case home
    case homeList = "home_list"
    case categoryFilter = "category_filter"
    case mainAdBanner = "main_ad_banner"
    case searchAddress = "search_address"
    
    /// Write
    case writeAddress = "write_address"
    case writeAddressPopup = "write_address_popop"
    case writeAddressDetail = "write_address_detail"
    case writeAddressBossBottomSheet = "write_address_boss_bottom_sheet"
    case writeDetailComplete = "write_detail_complete"
    case writeDetailAdditionalInfo = "write_detail_additional_info"
    case writeDetailCategory = "write_detail_category"
    case writeDetailCategoryBottomSheet = "write_detail_category_botom_sheet"
    case writeDetailInfo = "write_detail_info"
    case writeDetailMenu = "write_detail_menu"
    case categorySelection = "category_selection"
    case editStore = "edit_store"
    case editStoreInfo = "edit_store_info"
    
    /// Store
    case storeDetail = "store_detail"
    case uploadPhoto = "upload_photo"
    case reviewList = "review_list"
    case reportStore = "report_store"
    case reviewBottomSheet = "review_bottom_sheet"
    case visitStore = "visit_store"
    case bossStoreDetail = "boss_store_detail"
    case bossStoreReview = "boss_store_review"
    case bossStoreReviewWrite = "boss_store_review_write"
    case bossStorePhoto = "boss_store_photo"
    
    /// Community
    case community = "community"
    case pollDetail = "poll_detail"
    case pollList = "poll_list"
    case reportPoll = "report_poll"
    case reportReview = "report_review"
    case createPoll = "careate_poll"
    
    // MyPage
    case myPage = "my_page"
    case registeredStore = "registered_store"
    case visitedList = "visited_list"
    case clickReview = "click_review"
    case myReview = "my_review"
    case myMedal = "my_medal"
    case myBookmarkList = "my_bookmark_list"
    case editBookmarkList = "edit_bookmark_list"
    case bookmarkListViewer = "bookmark_list_viewer"
    case setting
    case editNickname = "edit_nickname"
    case qna
    case faq
    case teamInfo = "team_info"
}
