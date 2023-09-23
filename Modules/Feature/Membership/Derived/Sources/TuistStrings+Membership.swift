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
