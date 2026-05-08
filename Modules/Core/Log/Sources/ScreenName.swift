import Foundation

public struct ScreenName: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension ScreenName {
    static let empty = ScreenName(rawValue: "empty")

    static let splash = ScreenName(rawValue: "splash")

    static let markerPopup = ScreenName(rawValue: "marker_popup")

    // Membership
    static let signIn = ScreenName(rawValue: "sign_in")
    static let signUp = ScreenName(rawValue: "sign_up")
    static let accountInfo = ScreenName(rawValue: "account_info")

    // Home
    static let home = ScreenName(rawValue: "home")
    static let homeList = ScreenName(rawValue: "home_list")
    static let categoryFilter = ScreenName(rawValue: "category_filter")
    static let mainAdBanner = ScreenName(rawValue: "main_ad_banner")
    static let searchAddress = ScreenName(rawValue: "search_address")

    /// Write
    static let writeAddress = ScreenName(rawValue: "write_address")
    static let writeAddressPopup = ScreenName(rawValue: "write_address_popup")
    static let writeAddressDetail = ScreenName(rawValue: "write_address_detail")
    static let writeAddressBossBottomSheet = ScreenName(rawValue: "write_address_boss_bottom_sheet")
    static let writeDetailComplete = ScreenName(rawValue: "write_detail_complete")
    static let writeDetailAdditionalInfo = ScreenName(rawValue: "write_detail_additional_info")
    static let writeDetailCategory = ScreenName(rawValue: "write_detail_category")
    static let writeDetailCategoryBottomSheet = ScreenName(rawValue: "write_detail_category_botom_sheet")
    static let writeDetailInfo = ScreenName(rawValue: "write_detail_info")
    static let writeDetailMenu = ScreenName(rawValue: "write_detail_menu")
    static let categorySelection = ScreenName(rawValue: "category_selection")
    static let editStore = ScreenName(rawValue: "edit_store")
    static let editStoreInfo = ScreenName(rawValue: "edit_store_info")

    /// Store
    static let storeDetail = ScreenName(rawValue: "store_detail")
    static let uploadPhoto = ScreenName(rawValue: "upload_photo")
    static let reviewList = ScreenName(rawValue: "review_list")
    static let reportStore = ScreenName(rawValue: "report_store")
    static let reviewBottomSheet = ScreenName(rawValue: "review_bottom_sheet")
    static let visitStore = ScreenName(rawValue: "visit_store")
    static let bossStoreDetail = ScreenName(rawValue: "boss_store_detail")
    static let bossStoreReview = ScreenName(rawValue: "boss_store_review")
    static let bossStoreReviewWrite = ScreenName(rawValue: "boss_store_review_write")
    static let bossStorePhoto = ScreenName(rawValue: "boss_store_photo")
    static let storeDetailBridge = ScreenName(rawValue: "store_detail_bridge")
    static let storeContributors = ScreenName(rawValue: "store_contributors")

    /// Community
    static let community = ScreenName(rawValue: "community")
    static let pollDetail = ScreenName(rawValue: "poll_detail")
    static let pollList = ScreenName(rawValue: "poll_list")
    static let reportPoll = ScreenName(rawValue: "report_poll")
    static let reportReview = ScreenName(rawValue: "report_review")
    static let createPoll = ScreenName(rawValue: "careate_poll")

    // MyPage
    static let myPage = ScreenName(rawValue: "my_page")
    static let registeredStore = ScreenName(rawValue: "registered_store")
    static let visitedList = ScreenName(rawValue: "visited_list")
    static let clickReview = ScreenName(rawValue: "click_review")
    static let myReview = ScreenName(rawValue: "my_review")
    static let myMedal = ScreenName(rawValue: "my_medal")
    static let myBookmarkList = ScreenName(rawValue: "my_bookmark_list")
    static let editBookmarkList = ScreenName(rawValue: "edit_bookmark_list")
    static let bookmarkListViewer = ScreenName(rawValue: "bookmark_list_viewer")
    static let setting = ScreenName(rawValue: "setting")
    static let editNickname = ScreenName(rawValue: "edit_nickname")
    static let qna = ScreenName(rawValue: "qna")
    static let faq = ScreenName(rawValue: "faq")
    static let teamInfo = ScreenName(rawValue: "team_info")

    // Feed
    static let feedList = ScreenName(rawValue: "feed_list")
}
