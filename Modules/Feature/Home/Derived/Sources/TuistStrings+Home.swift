// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum HomeStrings: Sendable {
  /// 지도뷰
  public static let categoryFileterMapView = HomeStrings.tr("Localization", "category_fileter_map_view")
  /// new
  public static let categoryFilterNew = HomeStrings.tr("Localization", "category_filter_new")
  /// 이 안에 네 최애 하나쯤은 있겠지!
  public static let categoryFilterTitle = HomeStrings.tr("Localization", "category_filter_title")
  /// 사장님 직영
  public static let homeBossStoreTag = HomeStrings.tr("Localization", "home_boss_store_tag")
  /// 전체 메뉴
  public static let homeCategoryFilterButton = HomeStrings.tr("Localization", "home_category_filter_button")
  /// 다른 주소로 검색하거나 직접 제보해보세요!
  public static let homeEmptyDescription = HomeStrings.tr("Localization", "home_empty_description")
  /// 주변 2km 이내에\n가게가 없어요.
  public static let homeEmptyTitle = HomeStrings.tr("Localization", "home_empty_title")
  /// · 최근 한 달 내에 방문 인증 성공 내역이 있어요.\n· 신규로 생성된 가게에요.
  public static let homeFilterTooltipDescription = HomeStrings.tr("Localization", "home_filter_tooltip_description")
  /// 최근 활동이 있는 가게만 볼 수 있어요!
  public static let homeFilterTooltipTitle = HomeStrings.tr("Localization", "home_filter_tooltip_title")
  /// 전체 메뉴
  public static let homeListHeaderTotal = HomeStrings.tr("Localization", "home_list_header_total")
  /// 방문 인증 가게
  public static let homeListIsOnlyCertified = HomeStrings.tr("Localization", "home_list_is_only_certified")
  /// 리스트뷰
  public static let homeListViewButton = HomeStrings.tr("Localization", "home_list_view_button")
  /// 사장님 직영점만
  public static let homeOnlyBossButton = HomeStrings.tr("Localization", "home_only_boss_button")
  /// 최근 활동
  public static let homeRecentActivity = HomeStrings.tr("Localization", "home_recent_activity")
  /// 현재 지도에서 가게 재검색
  public static let homeResearchButton = HomeStrings.tr("Localization", "home_research_button")
  /// 거리순 보기
  public static let homeSortingButtonDistance = HomeStrings.tr("Localization", "home_sorting_button_distance")
  /// 최근 등록순 보기
  public static let homeSortingButtonLatest = HomeStrings.tr("Localization", "home_sorting_button_latest")
  /// 방문하기
  public static let homeVisitButton = HomeStrings.tr("Localization", "home_visit_button")
  /// 현재 내 위치와 가까운 가게를 찾기 위해 위치 권한이 필요합니다. 설정에서 위치 권한을 허용시켜주세요.
  public static let locationDenyDescription = HomeStrings.tr("Localization", "location_deny_description")
  /// 위치 권한 거절
  public static let locationDenyTitle = HomeStrings.tr("Localization", "location_deny_title")

  public enum Home: Sendable {
  /// 🍀 이 동네 가게 소식!
    public static let feedButton = HomeStrings.tr("Localization", "home.feed_button")
    /// 여기가 바로 핫플 🔥
    public static let feedButton2 = HomeStrings.tr("Localization", "home.feed_button_2")
  }

  public enum HomeList: Sendable {

    public enum Empty: Sendable {
    /// 다른 주소로 검색하거나 직접 제보해보세요!
      public static let description = HomeStrings.tr("Localization", "home_list.empty.description")
      /// 주변 2km 이내에 가게가 없어요.
      public static let title = HomeStrings.tr("Localization", "home_list.empty.title")
    }
  }

  public enum SearchAddress: Sendable {
  /// 구, 동, 건물명, 역 등으로 검색
    public static let placeholder = HomeStrings.tr("Localization", "search_address.placeholder")
    /// 위치 검색
    public static let title = HomeStrings.tr("Localization", "search_address.title")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension HomeStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
