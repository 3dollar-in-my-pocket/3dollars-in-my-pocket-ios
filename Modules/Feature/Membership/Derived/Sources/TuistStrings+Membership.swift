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
  /// Sign in with Apple
  public static let signinApple = MembershipStrings.tr("Localization", "signin_apple")
  /// 카카오 계정으로 로그인
  public static let signinKakao = MembershipStrings.tr("Localization", "signin_kakao")
  /// 로그인 없이 둘러보기
  public static let signinNonMember = MembershipStrings.tr("Localization", "signin_non_member")
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
