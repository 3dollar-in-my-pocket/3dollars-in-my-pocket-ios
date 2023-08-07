// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum HomeStrings {
  /// 지도뷰
  public static let categoryFileterMapView = HomeStrings.tr("Localization", "category_fileter_map_view")
  /// new
  public static let categoryFilterNew = HomeStrings.tr("Localization", "category_filter_new")
  /// 이 안에 네 최애 하나쯤은 있겠지!
  public static let categoryFilterTitle = HomeStrings.tr("Localization", "category_filter_title")
  /// 전체 메뉴
  public static let homeCategoryFilterButton = HomeStrings.tr("Localization", "home_category_filter_button")
  /// 다른 주소로 검색하거나 직접 제보해보세요!
  public static let homeEmptyDescription = HomeStrings.tr("Localization", "home_empty_description")
  /// 주변 2km 이내에\n가게가 없어요.
  public static let homeEmptyTitle = HomeStrings.tr("Localization", "home_empty_title")
  /// 리스트뷰
  public static let homeListViewButton = HomeStrings.tr("Localization", "home_list_view_button")
  /// 사장님 직영점만
  public static let homeOnlyBossButton = HomeStrings.tr("Localization", "home_only_boss_button")
  /// 현재 지도에서 가게 재검색
  public static let homeResearchButton = HomeStrings.tr("Localization", "home_research_button")
  /// 거리순 보기
  public static let homeSortingButtonDistance = HomeStrings.tr("Localization", "home_sorting_button_distance")
  /// 최근 등록순 보기
  public static let homeSortingButtonLatest = HomeStrings.tr("Localization", "home_sorting_button_latest")
  /// 방문하기
  public static let homeVisitButton = HomeStrings.tr("Localization", "home_visit_button")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension HomeStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = HomeResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
