// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum ThreeDollarInMyPocketStrings {
  /// 다중선택 가능
  public static let addCategoryMulti = ThreeDollarInMyPocketStrings.tr("Localization", "add_category_multi")
  /// 총 %d개 선택하기
  public static func addCategoryNumberFormat(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "add_category_number_format", p1)
  }
  /// 카테고리 선택
  public static let addCategoryTitle = ThreeDollarInMyPocketStrings.tr("Localization", "add_category_title")
  /// 리스트에 대한 한줄평을 입력해주세요! 공유 시 사용됩니다.
  public static let bookmarkEditPlaceholderDescription = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_edit_placeholder_description")
  /// 저장하기
  public static let bookmarkEditSave = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_edit_save")
  /// 정보 수정하기
  public static let bookmarkEditTitle = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_edit_title")
  /// 삭제하기
  public static let bookmarkListDelete = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_delete")
  /// 전체 삭제
  public static let bookmarkListDeleteAll = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_delete_all")
  /// 취소
  public static let bookmarkListDeletePopupCancel = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_delete_popup_cancel")
  /// 삭제
  public static let bookmarkListDeletePopupDelete = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_delete_popup_delete")
  /// 나의 즐겨찾기 리스트를\n모두 삭제할까요?
  public static let bookmarkListDeletePopupTitle = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_delete_popup_title")
  /// 정보 수정하기
  public static let bookmarkListEditFolder = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_edit_folder")
  /// 즐겨찾기 리스트가 없어요.\n가게 상세에서 추가해주세요!
  public static let bookmarkListEmpty = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_empty")
  /// 완료
  public static let bookmarkListFinish = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_finish")
  /// 즐겨찾기
  public static let bookmarkListTitle = ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_list_title")
  /// %d개의 리스트
  public static func bookmarkViewerCountFormat(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_viewer_count_format", p1)
  }
  /// %@님의 즐겨찾기
  public static func bookmarkViewerNameFormat(_ p1: Any) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "bookmark_viewer_name_format", String(describing: p1))
  }
  /// 지금은 준비중이에요! 🧑‍🍳
  public static let bossStoreClosed = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_closed")
  /// 휴무
  public static let bossStoreClosedDay = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_closed_day")
  /// 아직 등록된 정보가 없어요.
  public static let bossStoreEmptyMenu = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_empty_menu")
  /// 리뷰 남기기
  public static let bossStoreFeedback = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_feedback")
  /// 여러개의 리뷰를 선택할 수 있습니다.
  public static let bossStoreFeedbackHeaderDescription = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_feedback_header_description")
  /// 푸드트럭은\n어떠셨나요?
  public static let bossStoreFeedbackHeaderTitle = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_feedback_header_title")
  /// 리뷰 남기기 완료!
  public static let bossStoreFeedbackSendFeedback = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_feedback_send_feedback")
  /// 소중한 리뷰가 사장님께 전달되었습니다!
  public static let bossStoreFeedbackSuccess = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_feedback_success")
  /// 리뷰 남기기
  public static let bossStoreFeedbackTitle = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_feedback_title")
  /// 사장님 한마디
  public static let bossStoreIntroduction = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_introduction")
  /// 메뉴 정보
  public static let bossStoreMenuInfo = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_menu_info")
  /// %d개의 메뉴가 더 있습니다.
  public static func bossStoreMoreMenu(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_more_menu", p1)
  }
  /// 공유하기
  public static let bossStoreShare = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_share")
  /// SNS
  public static let bossStoreSns = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_sns")
  /// 바로가기
  public static let bossStoreSnsShortcut = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_sns_shortcut")
  /// 가게 평가
  public static let bossStoreStoreFeedback = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_store_feedback")
  /// 가게 정보
  public static let bossStoreStoreInfo = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_store_info")
  /// 영업 일정
  public static let bossStoreWorkday = ThreeDollarInMyPocketStrings.tr("Localization", "boss_store_workday")
  /// 붕어빵
  public static let categoryBungeoppang = ThreeDollarInMyPocketStrings.tr("Localization", "category_bungeoppang")
  /// 근처에 가게가 없어요.
  public static let categoryEmpty = ThreeDollarInMyPocketStrings.tr("Localization", "category_empty")
  /// 계란빵,
  public static let categoryGyeranppang = ThreeDollarInMyPocketStrings.tr("Localization", "category_gyeranppang")
  /// 호떡아
  public static let categoryHotteok = ThreeDollarInMyPocketStrings.tr("Localization", "category_hotteok")
  /// 붕어빵 만나기 30초 전
  public static let categoryListBungeoppang = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_bungeoppang")
  /// 인증된 가게만
  public static let categoryListCertificated = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_certificated")
  /// 456번째 달고나
  public static let categoryListDalgona = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_dalgona")
  /// 주변에 가게가 없어요.
  public static let categoryListEmpty = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_empty")
  /// 날 쏴줘 어묵 탕!
  public static let categoryListEomuk = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_eomuk")
  /// 사계절 네가 생각나\n국화빵
  public static let categoryListGukwappang = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_gukwappang")
  /// 널 생각하면 목이 막혀,\n군고구마
  public static let categoryListGungoguma = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_gungoguma")
  /// 버터까지 발라서 굽겠어\n군옥수수
  public static let categoryListGunoksusu = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_gunoksusu")
  /// 계란빵, 내입으로
  public static let categoryListGyeranppang = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_gyeranppang")
  /// 100m 이내
  public static let categoryListHeaderDistance100 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_distance100")
  /// 1km 이내
  public static let categoryListHeaderDistance1000 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_distance1000")
  /// 50m 이내
  public static let categoryListHeaderDistance50 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_distance50")
  /// 500m 이내
  public static let categoryListHeaderDistance500 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_distance500")
  /// 1km 밖
  public static let categoryListHeaderDistanceOver1000 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_distanceOver1000")
  /// 0점 이상
  public static let categoryListHeaderReview0 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_review0")
  /// 1점 이상
  public static let categoryListHeaderReview1 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_review1")
  /// 2점 이상
  public static let categoryListHeaderReview2 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_review2")
  /// 3점 이상
  public static let categoryListHeaderReview3 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_review3")
  /// 4점 이상
  public static let categoryListHeaderReview4 = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_header_review4")
  /// 호떡아 기다려
  public static let categoryListHotteok = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_hotteok")
  /// 꼬치꼬치 캐묻지마 ♥︎
  public static let categoryListKkochi = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_kkochi")
  /// 순대, 제발 내장 많이 주세요.
  public static let categoryListSundae = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_sundae")
  /// 문어빵 다내꺼야
  public static let categoryListTakoyaki = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_takoyaki")
  /// 너네 사이에 나도 껴주라,\n토스트
  public static let categoryListToast = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_toast")
  /// 땅콩빵, 오늘 널 갖겠어
  public static let categoryListTtangkongppang = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_ttangkongppang")
  /// 떡볶이...\n너 500원이었잖아
  public static let categoryListTteokbokki = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_tteokbokki")
  /// 넌 어쩜 이름도\n와플일까?
  public static let categoryListWaffle = ThreeDollarInMyPocketStrings.tr("Localization", "category_list_waffle")
  /// 거리순
  public static let categoryOrderingDistance = ThreeDollarInMyPocketStrings.tr("Localization", "category_ordering_distance")
  /// 별점순
  public static let categoryOrderingReview = ThreeDollarInMyPocketStrings.tr("Localization", "category_ordering_review")
  /// 만나기 30초 전
  public static let categorySubTextBungeoppang = ThreeDollarInMyPocketStrings.tr("Localization", "category_sub_text_bungeoppang")
  /// 내 입으로
  public static let categorySubTextGyeranppang = ThreeDollarInMyPocketStrings.tr("Localization", "category_sub_text_gyeranppang")
  /// 기다려
  public static let categorySubTextHotteok = ThreeDollarInMyPocketStrings.tr("Localization", "category_sub_text_hotteok")
  /// 다 내꺼야
  public static let categorySubTextTakoyaki = ThreeDollarInMyPocketStrings.tr("Localization", "category_sub_text_takoyaki")
  /// 문어빵,
  public static let categoryTakoyaki = ThreeDollarInMyPocketStrings.tr("Localization", "category_takoyaki")
  /// 이 안에 네 최애 하나쯤은 있겠지!
  public static let categoryTitle = ThreeDollarInMyPocketStrings.tr("Localization", "category_title")
  /// 수정할래요
  public static let editNicknameEditLabel = ThreeDollarInMyPocketStrings.tr("Localization", "edit_nickname_edit_label")
  /// 를
  public static let editNicknameLabel1 = ThreeDollarInMyPocketStrings.tr("Localization", "edit_nickname_label1")
  /// 로
  public static let editNicknameLabel2 = ThreeDollarInMyPocketStrings.tr("Localization", "edit_nickname_label2")
  /// 닉네임 입력
  public static let editNicknamePlaceholder = ThreeDollarInMyPocketStrings.tr("Localization", "edit_nickname_placeholder")
  /// 닉네임 수정
  public static let editNicknameTitle = ThreeDollarInMyPocketStrings.tr("Localization", "edit_nickname_title")
  /// API통신중 요류 발생.\nurl: %s\nmessage: %s
  public static func errorCrashlyticsFormat(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "error_crashlytics_format", p1, p2)
  }
  /// 데이터를 가져오는 도중 오류가 발생했습니다.\n다시 시도해주세요.
  public static let errorFailedToJson = ThreeDollarInMyPocketStrings.tr("Localization", "error_failed_to_json")
  /// 위치 오류가 발생되었습니다.\n에러가 개발자에게 보고됩니다.
  public static let errorLocationDefaultMessage = ThreeDollarInMyPocketStrings.tr("Localization", "error_location_default_message")
  /// 위치 오류 발생
  public static let errorLocationDefaultTitle = ThreeDollarInMyPocketStrings.tr("Localization", "error_location_default_title")
  /// 현재 내 위치와 가까운 가게를 찾기 위해 위치 권한이 필요합니다. 설정에서 위치 권한을 허용시켜주세요.
  public static let errorLocationPermissionDeniedMessage = ThreeDollarInMyPocketStrings.tr("Localization", "error_location_permission_denied_message")
  /// 위치 권한 거절
  public static let errorLocationPermissionDeniedTitle = ThreeDollarInMyPocketStrings.tr("Localization", "error_location_permission_denied_title")
  /// 현재 위치가 확인되지 않습니다.\n잠시 후 다시 시도해주세요.
  public static let errorLocationUnknownMessage = ThreeDollarInMyPocketStrings.tr("Localization", "error_location_unknown_message")
  /// 알 수 없는 위치
  public static let errorLocationUnknownTitle = ThreeDollarInMyPocketStrings.tr("Localization", "error_location_unknown_title")
  /// 서버점검중입니다.\n잠시후 다시 시도해주세요.
  public static let errorMaintenanceMessage = ThreeDollarInMyPocketStrings.tr("Localization", "error_maintenance_message")
  /// 서버점검
  public static let errorMaintenanceTitle = ThreeDollarInMyPocketStrings.tr("Localization", "error_maintenance_title")
  /// 알수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해주세요!
  public static let errorUnknown = ThreeDollarInMyPocketStrings.tr("Localization", "error_unknown")
  /// 서버와 통신중 오류가 발생했습니다.\n다시 시도해주세요.
  public static let errorValueIsNil = ThreeDollarInMyPocketStrings.tr("Localization", "error_value_is_nil")
  /// 어떤 점이 궁금하셨나요?
  public static let faqQuestion = ThreeDollarInMyPocketStrings.tr("Localization", "faq_question")
  /// FAQ
  public static let faqTitle = ThreeDollarInMyPocketStrings.tr("Localization", "faq_title")
  /// 금요일
  public static let fridayFull = ThreeDollarInMyPocketStrings.tr("Localization", "friday_full")
  /// 다른 주소로 검색해보세요!
  public static let homeEmptyBossDescription = ThreeDollarInMyPocketStrings.tr("Localization", "home_empty_boss_description")
  /// 주변에 푸드트럭이 없어요.
  public static let homeEmptyBossTitle = ThreeDollarInMyPocketStrings.tr("Localization", "home_empty_boss_title")
  /// 다른 주소로 검색하거나\n직접 제보해보세요!
  public static let homeEmptyDescription = ThreeDollarInMyPocketStrings.tr("Localization", "home_empty_description")
  /// 주변에 가게가 없어요.
  public static let homeEmptyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "home_empty_title")
  /// 준비중
  public static let homeFoodtruckClosed = ThreeDollarInMyPocketStrings.tr("Localization", "home_foodtruck_closed")
  /// 여기를 눌러 푸드트럭 위치를 볼 수 있어요!\n이제 푸드트럭 음식도 즐겨보세요💚
  public static let homeFoodtruckTooltip = ThreeDollarInMyPocketStrings.tr("Localization", "home_foodtruck_tooltip")
  /// 현재 지도에서 가게 재검색
  public static let homeResearch = ThreeDollarInMyPocketStrings.tr("Localization", "home_research")
  /// 방문하기
  public static let homeVisit = ThreeDollarInMyPocketStrings.tr("Localization", "home_visit")
  /// 일시적인 오류가 발생했어요..ㅠㅠ\n잠시 후 다시 시도해주세요!
  public static let httpErrorBadGateway = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_bad_gateway")
  /// 요청에 오류가 있습니다.\n다시 확인해주세요.
  public static let httpErrorBadRequest = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_bad_request")
  /// 탈퇴한 사용자입니다.
  public static let httpErrorForbidden = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_forbidden")
  /// 서버에서 오류가 발생했습니다.\n잠시 후 다시 시도해주세요!
  public static let httpErrorInternalServerError = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_internal_server_error")
  /// 서버 점검중입니다.\n잠시 후 다시 시도해주세요.
  public static let httpErrorMaintenance = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_maintenance")
  /// 없는 데이터입니다.
  public static let httpErrorNotFound = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_not_found")
  /// 일시적인 오류가 발생했어요..ㅠㅠ\n잠시 후 다시 시도해주세요!
  public static let httpErrorTimeout = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_timeout")
  /// 세션이 만료되었습니다.\n다시 로그인해주세요.
  public static let httpErrorUnauthorized = ThreeDollarInMyPocketStrings.tr("Localization", "http_error_unauthorized")
  /// Status code: %@\nrequest_url: %@\nresponse: %@
  public static func httpErrorUndefiend(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "http_error_undefiend", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// 현재 내 위치와 가까운 가게를 찾기 위해 위치 권한이 필요합니다. 설정에서 위치 권한을 허용시켜주세요.
  public static let locationDenyDescription = ThreeDollarInMyPocketStrings.tr("Localization", "location_deny_description")
  /// 위치 권한 거절
  public static let locationDenyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "location_deny_title")
  /// 현재 위치가 확인되지 않습니다.\n잠시 후 다시 시도해주세요.
  public static let locationUnknownDescription = ThreeDollarInMyPocketStrings.tr("Localization", "location_unknown_description")
  /// 위치 오류가 발생되었습니다.\n에러가 개발자에게 보고됩니다.
  public static let locationUnknownErrorDescription = ThreeDollarInMyPocketStrings.tr("Localization", "location_unknown_error_description")
  /// 위치 오류 발생
  public static let locationUnknownErrorTitle = ThreeDollarInMyPocketStrings.tr("Localization", "location_unknown_error_title")
  /// 알 수 없는 위치 권한
  public static let locationUnknownStatus = ThreeDollarInMyPocketStrings.tr("Localization", "location_unknown_status")
  /// 알 수 없는 위치
  public static let locationUnknownTitle = ThreeDollarInMyPocketStrings.tr("Localization", "location_unknown_title")
  /// 월요일
  public static let mondayFull = ThreeDollarInMyPocketStrings.tr("Localization", "monday_full")
  /// 내 칭호
  public static let myMedalTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_medal_title")
  /// 내 음식 플리 들어볼래?
  public static let myPageBookmarkDescription = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_bookmark_description")
  /// 가게 상세에서 추가해주세요.
  public static let myPageBookmarkEmptyDescription = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_bookmark_empty_description")
  /// 즐겨찾기 리스트가 없어요!
  public static let myPageBookmarkEmptyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_bookmark_empty_title")
  /// 내 칭호
  public static let myPageMedals = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_medals")
  /// 더보기
  public static let myPageMore = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_more")
  /// 내가 쓴 리뷰
  public static let myPageRegisteredReview = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_registered_review")
  /// 제보한 가게
  public static let myPageRegisteredStore = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_registered_store")
  /// 마이 페이지
  public static let myPageTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_title")
  /// 전체보기
  public static let myPageTotal = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_total")
  /// 방문 인증
  public static let myPageVisit = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_visit")
  /// 최근 내가 들린 가게는?
  public static let myPageVisitDescription = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_visit_description")
  /// 방문 인증으로 정확도를 높혀봐요.
  public static let myPageVisitHistoryEmptyDescription = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_visit_history_empty_description")
  /// 방문 인증 내역이 없어요!
  public static let myPageVisitHistoryEmptyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_page_visit_history_empty_title")
  /// %d개의 리뷰
  public static func myReviewCountFormat(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "my_review_count_format", p1)
  }
  /// 아직 작성한 리뷰가 없어요!
  public static let myReviewEmptyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_review_empty_title")
  /// 내가 쓴 리뷰
  public static let myReviewTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_review_title")
  /// 방문을 인증해 보고 정확도를 높혀봐요
  public static let myVisitHistoryEmptyDescription = ThreeDollarInMyPocketStrings.tr("Localization", "my_visit_history_empty_description")
  /// 방문 인증 내역이 없어요!
  public static let myVisitHistoryEmptyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_visit_history_empty_title")
  /// 방문 인증 내역
  public static let myVisitHistoryTitle = ThreeDollarInMyPocketStrings.tr("Localization", "my_visit_history_title")
  /// 이미 존재하는 닉네임입니다.
  public static let nicknameAlreayExisted = ThreeDollarInMyPocketStrings.tr("Localization", "nickname_alreay_existed")
  /// 저는 닉네임
  public static let nicknameLabel1 = ThreeDollarInMyPocketStrings.tr("Localization", "nickname_label_1")
  /// 로
  public static let nicknameLabel2 = ThreeDollarInMyPocketStrings.tr("Localization", "nickname_label_2")
  /// 시작할래요
  public static let nicknameLabel3 = ThreeDollarInMyPocketStrings.tr("Localization", "nickname_label_3")
  /// 닉네임 입력
  public static let nicknamePlaceholder = ThreeDollarInMyPocketStrings.tr("Localization", "nickname_placeholder")
  /// 설정에서 해당 권한을 허용해 주세요!!
  public static let permissionDeniedDescription = ThreeDollarInMyPocketStrings.tr("Localization", "permission_denied_description")
  /// 권한이 거절되었어요😭
  public static let permissionDeniedTitle = ThreeDollarInMyPocketStrings.tr("Localization", "permission_denied_title")
  /// 설정
  public static let permissionSettingButton = ThreeDollarInMyPocketStrings.tr("Localization", "permission_setting_button")
  /// 취소
  public static let permissionSettingCancel = ThreeDollarInMyPocketStrings.tr("Localization", "permission_setting_cancel")
  /// 사진 삭제시 복구할 수 없습니다.
  public static let photoDetailDeleteDescription = ThreeDollarInMyPocketStrings.tr("Localization", "photo_detail_delete_description")
  /// 사진을 삭제하시겠습니까?
  public static let photoDetailDeleteTitle = ThreeDollarInMyPocketStrings.tr("Localization", "photo_detail_delete_title")
  /// 사진 제보
  public static let photoDetailTitle = ThreeDollarInMyPocketStrings.tr("Localization", "photo_detail_title")
  /// 사진 미리보기
  public static let photoListTitle = ThreeDollarInMyPocketStrings.tr("Localization", "photo_list_title")
  /// 전체 동의하기
  public static let policyAgreeAll = ThreeDollarInMyPocketStrings.tr("Localization", "policy_agree_all")
  /// (선택) 마케팅 활용 및 광고성 정보 수신 동의
  public static let policyMarketingLabel = ThreeDollarInMyPocketStrings.tr("Localization", "policy_marketing_label")
  /// 동의하고 계속하기
  public static let policyNextButton = ThreeDollarInMyPocketStrings.tr("Localization", "policy_next_button")
  /// (필수) 이용약관 동의
  public static let policyPolicyLabel = ThreeDollarInMyPocketStrings.tr("Localization", "policy_policy_label")
  /// 닫기
  public static let popupClose = ThreeDollarInMyPocketStrings.tr("Localization", "popup_close")
  /// 오늘 하루 보지않기
  public static let popupDisableToday = ThreeDollarInMyPocketStrings.tr("Localization", "popup_disable_today")
  /// 개인정보처리방침
  public static let privacyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "privacy_title")
  /// 1:1문의
  public static let questionEmail = ThreeDollarInMyPocketStrings.tr("Localization", "question_email")
  /// FAQ
  public static let questionFaq = ThreeDollarInMyPocketStrings.tr("Localization", "question_faq")
  /// 문의사항
  public static let questionTitle = ThreeDollarInMyPocketStrings.tr("Localization", "question_title")
  /// 총 %d장/3장의 사진 등록
  public static func registerPhotoButtonFormat(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "register_photo_button_format", p1)
  }
  /// 사진 제보
  public static let registerPhotoTitle = ThreeDollarInMyPocketStrings.tr("Localization", "register_photo_title")
  /// %d개의 가게
  public static func registeredStoreCountFormat(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "registered_store_count_format", p1)
  }
  /// 발견한 가게를 제보해 보세요 :)
  public static let registeredStoreEmptyDescription = ThreeDollarInMyPocketStrings.tr("Localization", "registered_store_empty_description")
  /// 제보한 가게가 없어요!
  public static let registeredStoreEmptyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "registered_store_empty_title")
  /// 제보한 가게
  public static let registeredStoreTitle = ThreeDollarInMyPocketStrings.tr("Localization", "registered_store_title")
  /// 리뷰 수정
  public static let reviewModalModify = ThreeDollarInMyPocketStrings.tr("Localization", "review_modal_modify")
  /// 이 가게의 추천 내용을\n수정합니다.
  public static let reviewModalModifyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "review_modal_modify_title")
  /// 리뷰를 남겨주세요! (100자 이내)
  public static let reviewModalPlaceholder = ThreeDollarInMyPocketStrings.tr("Localization", "review_modal_placeholder")
  /// 리뷰 쓰기
  public static let reviewModalRegister = ThreeDollarInMyPocketStrings.tr("Localization", "review_modal_register")
  /// 이 가게를\n추천하시나요?
  public static let reviewModalTitle = ThreeDollarInMyPocketStrings.tr("Localization", "review_modal_title")
  /// 토요일
  public static let saturdayFull = ThreeDollarInMyPocketStrings.tr("Localization", "saturday_full")
  /// 구, 동, 건물명, 역 등으로 검색
  public static let searchAddressPlaceholder = ThreeDollarInMyPocketStrings.tr("Localization", "search_address_placeholder")
  /// 위치 검색
  public static let searchAddressTitle = ThreeDollarInMyPocketStrings.tr("Localization", "search_address_title")
  /// 로그아웃 하시겠습니까?
  public static let settingLogoutTitle = ThreeDollarInMyPocketStrings.tr("Localization", "setting_logout_title")
  /// 가슴속 3천원 마케팅 수신 동의
  public static let settingMarketing = ThreeDollarInMyPocketStrings.tr("Localization", "setting_marketing")
  /// 이용 약관
  public static let settingMenuPolicy = ThreeDollarInMyPocketStrings.tr("Localization", "setting_menu_policy")
  /// 개인정보처리방침
  public static let settingMenuPrivacy = ThreeDollarInMyPocketStrings.tr("Localization", "setting_menu_privacy")
  /// 푸시 알림
  public static let settingMenuPush = ThreeDollarInMyPocketStrings.tr("Localization", "setting_menu_push")
  /// 문의사항
  public static let settingMenuQuestion = ThreeDollarInMyPocketStrings.tr("Localization", "setting_menu_question")
  /// 닉네임 수정
  public static let settingNicknameModify = ThreeDollarInMyPocketStrings.tr("Localization", "setting_nickname_modify")
  /// 로그아웃
  public static let settingSignOut = ThreeDollarInMyPocketStrings.tr("Localization", "setting_sign_out")
  /// 회원탈퇴 이후에 제보했던 가게와 작성한 댓글을 더이상 볼 수 없어요.\n정말로 탈퇴하시겠어요?
  public static let settingSignoutMessage = ThreeDollarInMyPocketStrings.tr("Localization", "setting_signout_message")
  /// 설정
  public static let settingTitle = ThreeDollarInMyPocketStrings.tr("Localization", "setting_title")
  /// 회원탈퇴
  public static let settingWithdrawal = ThreeDollarInMyPocketStrings.tr("Localization", "setting_withdrawal")
  /// 광고
  public static let sharedAdvertisement = ThreeDollarInMyPocketStrings.tr("Localization", "shared_advertisement")
  /// 자세히 보기 >
  public static let sharedAdvertisementMore = ThreeDollarInMyPocketStrings.tr("Localization", "shared_advertisement_more")
  /// 붕어빵
  public static let sharedCategoryBungeoppang = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_bungeoppang")
  /// 달고나
  public static let sharedCategoryDalgona = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_dalgona")
  /// 어묵
  public static let sharedCategoryEomuk = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_eomuk")
  /// 국화빵
  public static let sharedCategoryGukwappang = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_gukwappang")
  /// 군고구마
  public static let sharedCategoryGungoguma = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_gungoguma")
  /// 군옥수수
  public static let sharedCategoryGunoksusu = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_gunoksusu")
  /// 계란빵
  public static let sharedCategoryGyeranppang = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_gyeranppang")
  /// 호떡
  public static let sharedCategoryHotteok = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_hotteok")
  /// 꼬치
  public static let sharedCategoryKkochi = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_kkochi")
  /// 순대
  public static let sharedCategorySundae = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_sundae")
  /// 문어빵
  public static let sharedCategoryTakoyaki = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_takoyaki")
  /// 토스트
  public static let sharedCategoryToast = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_toast")
  /// 땅콩빵
  public static let sharedCategoryTtangkongppang = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_ttangkongppang")
  /// 떡볶이
  public static let sharedCategoryTteokbokki = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_tteokbokki")
  /// 와플
  public static let sharedCategoryWaffle = ThreeDollarInMyPocketStrings.tr("Localization", "shared_category_waffle")
  /// 편의점
  public static let sharedStoreTypeConvenienceStore = ThreeDollarInMyPocketStrings.tr("Localization", "shared_store_type_convenience_store")
  /// 길거리
  public static let sharedStoreTypeRoad = ThreeDollarInMyPocketStrings.tr("Localization", "shared_store_type_road")
  /// 매장
  public static let sharedStoreTypeStore = ThreeDollarInMyPocketStrings.tr("Localization", "shared_store_type_store")
  /// 가슴속 3천원에 로그인하고\n더 많은 기능을 사용해 보세요!
  public static let signInAnonymousDescription = ThreeDollarInMyPocketStrings.tr("Localization", "sign_in_anonymous_description")
  /// 비로그인 상태로 남겨주신 제보, 리뷰는 비로그인 상태로 일정 기간 접속하지 않거나 앱 삭제 시, 볼 수 없습니다.
  public static let signInAnonymousWarning = ThreeDollarInMyPocketStrings.tr("Localization", "sign_in_anonymous_warning")
  /// Apple로 로그인
  public static let signInWithApple = ThreeDollarInMyPocketStrings.tr("Localization", "sign_in_with_apple")
  /// 이미 가입한 계정이 있습니다.\n해당 계정으로 로그인 하시겠습니까?\n비로그인으로 활동한 이력들은 유지되지 않습니다
  public static let signInWithExistedAccount = ThreeDollarInMyPocketStrings.tr("Localization", "sign_in_with_existed_account")
  /// 카카오 계정으로 로그인
  public static let signInWithKakao = ThreeDollarInMyPocketStrings.tr("Localization", "sign_in_with_kakao")
  /// 로그인 없이 사용하기
  public static let signInWithoutId = ThreeDollarInMyPocketStrings.tr("Localization", "sign_in_without_id")
  /// 따끈따끈한 업데이트가 나왔어요!\n확인버튼을 눌러 업데이트를 진행해주세요!
  public static let splashNeedUpdateDescription = ThreeDollarInMyPocketStrings.tr("Localization", "splash_need_update_description")
  /// 업데이트 필요
  public static let splashNeedUpdateTitle = ThreeDollarInMyPocketStrings.tr("Localization", "splash_need_update_title")
  /// 이미 삭제요청한 가게에요.
  public static let storeDeleteAlreadyRequest = ThreeDollarInMyPocketStrings.tr("Localization", "store_delete_already_request")
  /// 3건 이상의 요청이 들어오면 자동 삭제됩니다.
  public static let storeDeleteDescription = ThreeDollarInMyPocketStrings.tr("Localization", "store_delete_description")
  /// 없어진 가게에요.
  public static let storeDeleteMenuNotExisted = ThreeDollarInMyPocketStrings.tr("Localization", "store_delete_menu_not_existed")
  /// 중복 제보된 가게에요.
  public static let storeDeleteMenuOverlap = ThreeDollarInMyPocketStrings.tr("Localization", "store_delete_menu_overlap")
  /// 부적절한 내용이 있어요.
  public static let storeDeleteMenuWrongContent = ThreeDollarInMyPocketStrings.tr("Localization", "store_delete_menu_wrong_content")
  /// 신고하기
  public static let storeDeleteRequestButton = ThreeDollarInMyPocketStrings.tr("Localization", "store_delete_request_button")
  /// 삭제요청 하시는\n이유가 궁금해요!
  public static let storeDeleteTitle = ThreeDollarInMyPocketStrings.tr("Localization", "store_delete_title")
  /// 방문 인증하기
  public static let storeDetailAddVisitHistory = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_add_visit_history")
  /// 앨범
  public static let storeDetailAlbum = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_album")
  /// 즐겨찾기
  public static let storeDetailBookmark = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_bookmark")
  /// 즐겨찾기가 추가 되었습니다!
  public static let storeDetailBookmarkToast = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_bookmark_toast")
  /// 카메라
  public static let storeDetailCamera = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_camera")
  /// 취소
  public static let storeDetailCancel = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_cancel")
  /// 출몰시기
  public static let storeDetailDays = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_days")
  /// 삭제요청
  public static let storeDetailDeleteRequest = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_delete_request")
  /// 댓글 삭제
  public static let storeDetailDeleteReview = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_delete_review")
  /// 상세 메뉴 없음
  public static let storeDetailEmptyMenu = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_empty_menu")
  /// 아직 방문 인증 내역이 없어요 :(
  public static let storeDetailEmptyVisitHistory = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_empty_visit_history")
  /// 사진제보
  public static let storeDetailHeaderAddPhoto = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_header_add_photo")
  /// 리뷰쓰기
  public static let storeDetailHeaderAddReview = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_header_add_review")
  /// %d개
  public static func storeDetailHeaderCount(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_header_count", p1)
  }
  /// 가게 정보
  public static let storeDetailHeaderInfo = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_header_info")
  /// 정보수정
  public static let storeDetailHeaderModifyInfo = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_header_modify_info")
  /// 가게사진
  public static let storeDetailHeaderPhoto = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_header_photo")
  /// 리뷰
  public static let storeDetailHeaderReview = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_header_review")
  /// 아직 등록된 정보가 없어요.
  public static let storeDetailInfoEmpty = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_info_empty")
  /// 카테고리 및 메뉴
  public static let storeDetailMenu = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_menu")
  /// %d개
  public static func storeDetailMenuFormat(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_menu_format", p1)
  }
  /// 댓글 수정
  public static let storeDetailModifyReview = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_modify_review")
  /// 모두보기
  public static let storeDetailMore = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_more")
  /// 더보기
  public static let storeDetailMorePhoto = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_more_photo")
  /// 결제방식
  public static let storeDetailPayment = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_payment")
  /// 카드
  public static let storeDetailPaymentCard = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_payment_card")
  /// 현금
  public static let storeDetailPaymentCash = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_payment_cash")
  /// 계좌이체
  public static let storeDetailPaymentTransfer = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_payment_transfer")
  /// 사진 제보
  public static let storeDetailRegisterPhoto = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_register_photo")
  /// 님의 제보
  public static let storeDetailReporter = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_reporter")
  /// 공유하기
  public static let storeDetailShare = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_share")
  /// 놀러가기
  public static let storeDetailShareButton = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_share_button")
  /// 당신은 붕어빵 셔틀에 당첨되셨습니다.\n지금 바로 가슴속 3천원을 설치하고 위치를 파악하여 미션을 수행하세요!
  public static let storeDetailShareDescription = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_share_description")
  /// 올 때 붕어빵, 잊지마!!!
  public static let storeDetailShareTitle = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_share_title")
  /// 가게형태
  public static let storeDetailType = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_type")
  /// 즐겨찾기가 삭제 되었습니다!
  public static let storeDetailUnbookmarkToast = ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_unbookmark_toast")
  /// 1달 동안 %d명이 다녀간 가게에요!
  public static func storeDetailVisitHistory(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "store_detail_visit_history", p1)
  }
  /// 가게 위치 수정
  public static let storeModifyAddressTitle = ThreeDollarInMyPocketStrings.tr("Localization", "store_modify_address_title")
  /// 가게 정보 수정
  public static let storeModifyTitle = ThreeDollarInMyPocketStrings.tr("Localization", "store_modify_title")
  /// 일요일
  public static let sundayFull = ThreeDollarInMyPocketStrings.tr("Localization", "sunday_full")
  /// 푸드트럭
  public static let tabFoodTruck = ThreeDollarInMyPocketStrings.tr("Localization", "tab_food_truck")
  /// 홈
  public static let tabHome = ThreeDollarInMyPocketStrings.tr("Localization", "tab_home")
  /// MY
  public static let tabMy = ThreeDollarInMyPocketStrings.tr("Localization", "tab_my")
  /// 길거리음식
  public static let tabStreetFood = ThreeDollarInMyPocketStrings.tr("Localization", "tab_street_food")
  /// 제보하기
  public static let tabWrite = ThreeDollarInMyPocketStrings.tr("Localization", "tab_write")
  /// 목요일
  public static let thursdayFull = ThreeDollarInMyPocketStrings.tr("Localization", "thursday_full")
  /// 화요일
  public static let tuesdayFull = ThreeDollarInMyPocketStrings.tr("Localization", "tuesday_full")
  /// 방문 실패
  public static let visitFail = ThreeDollarInMyPocketStrings.tr("Localization", "visit_fail")
  /// 이번 달 %d명이\n다녀간 가게에요!
  public static func visitHistoryTotalCount(_ p1: Int) -> String {
    return ThreeDollarInMyPocketStrings.tr("Localization", "visit_history_total_count", p1)
  }
  /// 방문 성공
  public static let visitSuccess = ThreeDollarInMyPocketStrings.tr("Localization", "visit_success")
  /// 가게 근처에서\n방문을 인증할 수 있어요!
  public static let visitTitleDisable = ThreeDollarInMyPocketStrings.tr("Localization", "visit_title_disable")
  /// 가게 도착!\n방문을 인증해보세요!
  public static let visitTitleEnable = ThreeDollarInMyPocketStrings.tr("Localization", "visit_title_enable")
  /// 수요일
  public static let wednesdayFull = ThreeDollarInMyPocketStrings.tr("Localization", "wednesday_full")
  /// 맛집 위치는 바로 여기!
  public static let writeAddressBottomTitle = ThreeDollarInMyPocketStrings.tr("Localization", "write_address_bottom_title")
  /// 이 위치로 하기
  public static let writeAddressButton = ThreeDollarInMyPocketStrings.tr("Localization", "write_address_button")
  /// 중복된 가게 제보인지 확인해 주세요.
  public static let writeAddressConfirmPopupDescription = ThreeDollarInMyPocketStrings.tr("Localization", "write_address_confirm_popup_description")
  /// 여기가 확실해요
  public static let writeAddressConfirmPopupOk = ThreeDollarInMyPocketStrings.tr("Localization", "write_address_confirm_popup_ok")
  /// 10m이내에 이미 제보된\n가게가 있어요! 
  public static let writeAddressConfirmPopupTitle = ThreeDollarInMyPocketStrings.tr("Localization", "write_address_confirm_popup_title")
  /// 주소를 알 수 없는 위치입니다.
  public static let writeAddressUnknown = ThreeDollarInMyPocketStrings.tr("Localization", "write_address_unknown")
  /// 수정
  public static let writeEditLocation = ThreeDollarInMyPocketStrings.tr("Localization", "write_edit_location")
  /// 가게 위치
  public static let writeLocation = ThreeDollarInMyPocketStrings.tr("Localization", "write_location")
  /// 추가하기
  public static let writeStoreAddCategory = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_add_category")
  /// 카테고리
  public static let writeStoreCategory = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_category")
  /// 출몰시기
  public static let writeStoreDays = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_days")
  /// 전체 삭제
  public static let writeStoreDeleteAllMenu = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_delete_all_menu")
  /// 금
  public static let writeStoreFriday = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_friday")
  /// 가게 정보
  public static let writeStoreInfo = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_info")
  /// 가게이름
  public static let writeStoreInfoName = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_info_name")
  /// ex. 신촌역 0번 출구
  public static let writeStoreInfoNamePlaceholder = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_info_name_placeholder")
  /// 상세 메뉴
  public static let writeStoreMenu = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_menu")
  /// 월
  public static let writeStoreMonday = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_monday")
  /// (선택)
  public static let writeStoreOption = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_option")
  /// 카드
  public static let writeStorePaymentCard = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_payment_card")
  /// 현금
  public static let writeStorePaymentCash = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_payment_cash")
  /// 다중선택 가능
  public static let writeStorePaymentMulti = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_payment_multi")
  /// 계좌이체
  public static let writeStorePaymentTransfer = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_payment_transfer")
  /// 결제방식
  public static let writeStorePaymentType = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_payment_type")
  /// 가게 등록하기
  public static let writeStoreRegisterButton = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_register_button")
  /// 토
  public static let writeStoreSaturday = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_saturday")
  /// 일
  public static let writeStoreSunday = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_sunday")
  /// 목
  public static let writeStoreThursday = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_thursday")
  /// 화
  public static let writeStoreTuesday = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_tuesday")
  /// 가게형태
  public static let writeStoreType = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_type")
  /// 편의점
  public static let writeStoreTypeConvenienceStore = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_type_convenience_store")
  /// 길거리
  public static let writeStoreTypeRoad = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_type_road")
  /// 매장
  public static let writeStoreTypeStore = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_type_store")
  /// 수
  public static let writeStoreWednesday = ThreeDollarInMyPocketStrings.tr("Localization", "write_store_wednesday")
  /// 가게 제보
  public static let writeTitle = ThreeDollarInMyPocketStrings.tr("Localization", "write_title")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension ThreeDollarInMyPocketStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = ThreeDollarInMyPocketResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
