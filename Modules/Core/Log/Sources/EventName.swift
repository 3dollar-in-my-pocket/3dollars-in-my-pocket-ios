import Foundation

public enum EventName: String {
    // 홈 화면
    case clickSignInApple = "click_sign_in_apple"
    case clickSignInKakao = "click_sign_in_kakao"
    case clickSignInAnonymous = "click_sign_in_anonymous"
    
    // 회원가입 화면
    case clickSignUp = "click_sign_up"
    
    // 홈 화면
    case clickStore = "click_store"
    case clickVisit = "click_visit"
    case clickCurrentLocation = "click_current_location"
    case clickMarker = "click_marker"
    case clickAddressField = "click_address_field"
    case clickCategoryFilter = "click_category_filter"
    case clickBossFilter = "click_boss_filter"
    case clickSorting = "click_sorting"
    case clickAdCard = "click_ad_card"
    case clickAdMarker = "click_ad_marker"
    case clickAddress = "click_address"
    
    // 카테고리 필터 화면
    case clickCategory = "click_category"
    case clickAdBanner = "click_ad_banner"
    
    // 홈 리스트 화면
    case clickOnlyVisit = "click_only_visit"
    
    // 메인 배너 팝업
    case clickNotShowToday = "click_not_show_today"
    case clickClose = "click_close"
    
    // 가제 제보 화면
    case clickSetAddress = "click_set_address"
    case clickAddressOk = "click_address_ok"
    case clickWriteStore = "click_write_store"
    
    // 마커 배너 팝업
    case clickBottomButton = "click_bottom_button"
    
    // 길거리 음식점 가게 상세 화면
    case clickFavorite = "click_favorite"
    case clickReport = "click_report"
    case clickShare = "click_share"
    case clickNavigation = "click_navigation"
    case clickWriteReview = "click_write_review"
    case clickCopyAddress = "click_copy_address"
    case clickZoomMap = "click_zoom_map"
    
    // 사진 업로드 화면
    case clickUpload = "click_upload"
    
    // 리뷰 리스트 화면
    case clickSort = "click_sort"
    case clickEditReview = "click_edit_review"
    
    // 길거리 음식점 리뷰 작성 바텀시트
    case clickReviewBottomButton = "click_review_bottom_button"
    
    // 가게 방문 인증 화면
    case clickVisitSuccess = "click_visit_success"
    case clickVisitFail = "click_visit_fail"
    
    // 사장님 가게 상세 화면
    case clickSns = "click_sns"
    case clickCopyAccount = "click_copy_account"
    
    // 커뮤니티 화면
    case clickPoll = "click_poll"
    case clickPollOption = "click_poll_option"
    case clickPollCategory = "click_poll_category"
    case clickDistrict = "click_district"
    case clickPopularFilter = "click_popular_filter"
    
    // 투표 리스트 화면
    case clickCreatePoll = "click_create_poll"
    
    // 투표 상세 화면
    case clickDeleteReview = "click_delete_review"
    
    // 마이 페이지 화면
    case clickMedal = "click_medal"
    case clickVisitedStore = "click_visited_store"
    case clickFavoritedStore = "click_favorited_store"
    case clickMyPoll = "click_my_poll"
}
