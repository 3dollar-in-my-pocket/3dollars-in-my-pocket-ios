// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum MembershipStrings {
  /// 지도뷰
  public static let categoryFileterMapView = MembershipStrings.tr("Localization", "category_fileter_map_view")
  /// new
  public static let categoryFilterNew = MembershipStrings.tr("Localization", "category_filter_new")
  /// 이 안에 네 최애 하나쯤은 있겠지!
  public static let categoryFilterTitle = MembershipStrings.tr("Localization", "category_filter_title")
  /// 전체 메뉴
  public static let homeCategoryFilterButton = MembershipStrings.tr("Localization", "home_category_filter_button")
  /// 다른 주소로 검색하거나 직접 제보해보세요!
  public static let homeEmptyDescription = MembershipStrings.tr("Localization", "home_empty_description")
  /// 주변 2km 이내에\n가게가 없어요.
  public static let homeEmptyTitle = MembershipStrings.tr("Localization", "home_empty_title")
  /// 전체 메뉴
  public static let homeListHeaderTotal = MembershipStrings.tr("Localization", "home_list_header_total")
  /// 방문 인증 가게
  public static let homeListIsOnlyCertified = MembershipStrings.tr("Localization", "home_list_is_only_certified")
  /// 리스트뷰
  public static let homeListViewButton = MembershipStrings.tr("Localization", "home_list_view_button")
  /// 사장님 직영점만
  public static let homeOnlyBossButton = MembershipStrings.tr("Localization", "home_only_boss_button")
  /// 현재 지도에서 가게 재검색
  public static let homeResearchButton = MembershipStrings.tr("Localization", "home_research_button")
  /// 거리순 보기
  public static let homeSortingButtonDistance = MembershipStrings.tr("Localization", "home_sorting_button_distance")
  /// 최근 등록순 보기
  public static let homeSortingButtonLatest = MembershipStrings.tr("Localization", "home_sorting_button_latest")
  /// 방문하기
  public static let homeVisitButton = MembershipStrings.tr("Localization", "home_visit_button")
  /// 중복된 이름이에요!
  public static let nicknameAlreayExisted = MembershipStrings.tr("Localization", "nickname_alreay_existed")
  /// 닉네임
  public static let nicknameLabel1 = MembershipStrings.tr("Localization", "nickname_label_1")
  /// 로 시작할래요
  public static let nicknameLabel2 = MembershipStrings.tr("Localization", "nickname_label_2")
  /// 닉네임을 입력해주세요.
  public static let nicknamePlaceholder = MembershipStrings.tr("Localization", "nickname_placeholder")
  /// 회원가입
  public static let nicknameSignup = MembershipStrings.tr("Localization", "nickname_signup")
  /// 전체 동의하기
  public static let policyAgreeAll = MembershipStrings.tr("Localization", "policy_agree_all")
  /// (선택) 마케팅 활용 및 광고성 정보 수신 동의
  public static let policyMarketingLabel = MembershipStrings.tr("Localization", "policy_marketing_label")
  /// 동의하고 계속하기
  public static let policyNextButton = MembershipStrings.tr("Localization", "policy_next_button")
  /// (필수) 이용약관 동의
  public static let policyPolicyLabel = MembershipStrings.tr("Localization", "policy_policy_label")
  /// 로그인 없이 둘러보기
  public static let signinAnonymous = MembershipStrings.tr("Localization", "signin_anonymous")
  /// 가슴속 3천원에 로그인하고\n더 많은 기능을 사용해 보세요!
  public static let signinAnonymousDescription = MembershipStrings.tr("Localization", "signin_anonymous_description")
  /// 비로그인 상태로 남겨주신 제보, 리뷰는 비로그인 상태로 일정 기간 접속하지 않거나 앱 삭제 시, 볼 수 없습니다.
  public static let signinAnonymousWarning = MembershipStrings.tr("Localization", "signin_anonymous_warning")
  /// Sign in with Apple
  public static let signinWithApple = MembershipStrings.tr("Localization", "signin_with_apple")
  /// 이미 가입한 계정이 있습니다.\n해당 계정으로 로그인 하시겠습니까?\n비로그인으로 활동한 이력들은 유지되지 않습니다
  public static let signinWithExistedAccount = MembershipStrings.tr("Localization", "signin_with_existed_account")
  /// 카카오 계정으로 로그인
  public static let signinWithKakao = MembershipStrings.tr("Localization", "signin_with_kakao")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension MembershipStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = MembershipResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
