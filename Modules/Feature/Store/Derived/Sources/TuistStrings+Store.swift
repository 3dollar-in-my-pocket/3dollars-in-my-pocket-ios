// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum StoreStrings {

  public enum StoreDetail {
    public enum BottomSticky {
      /// 즐겨찾기
      public static let save = StoreStrings.tr("Localization", "store_detail.bottom_sticky.save")
      /// 방문 인증하기
      public static let visit = StoreStrings.tr("Localization", "store_detail.bottom_sticky.visit")
    }
    public enum Menu {
      /// 길 안내
      public static let navigation = StoreStrings.tr("Localization", "store_detail.menu.navigation")
      /// 리뷰쓰기
      public static let review = StoreStrings.tr("Localization", "store_detail.menu.review")
      /// 공유하기
      public static let share = StoreStrings.tr("Localization", "store_detail.menu.share")
    }
    public enum Visit {
      public enum Format {
        /// 방문 실패 %d명
        public static func visitFail(_ p1: Int) -> String {
          return StoreStrings.tr("Localization", "store_detail.visit.format.visit_fail", p1)
        }
        /// 방문 성공 %d명
        public static func visitSuccess(_ p1: Int) -> String {
          return StoreStrings.tr("Localization", "store_detail.visit.format.visit_success", p1)
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension StoreStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = StoreResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
