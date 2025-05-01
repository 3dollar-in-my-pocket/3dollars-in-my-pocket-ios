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
public enum FeedStrings: Sendable {

  public enum FeedList: Sendable {
  /// 우리 동네 소식
    public static let title = FeedStrings.tr("Localization", "feed_list.title")

    public enum Empty: Sendable {
    /// 가게 등록, 리뷰 작성으로 가게 소식을 직접 등록해보세요!
      public static let description = FeedStrings.tr("Localization", "feed_list.empty.description")
      /// 아직 동네 가게 소식이 없어요.
      public static let title = FeedStrings.tr("Localization", "feed_list.empty.title")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension FeedStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
