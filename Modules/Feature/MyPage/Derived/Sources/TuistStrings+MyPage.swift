// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum MyPageStrings {

  public enum EditNickname {
    /// 닉네임 변경
    public static let edit = MyPageStrings.tr("Localization", "edit_nickname.edit")
    /// 닉네임이 변경되었습니다😄
    public static let successEdit = MyPageStrings.tr("Localization", "edit_nickname.success_edit")
    /// 닉네임 수정
    public static let title = MyPageStrings.tr("Localization", "edit_nickname.title")
    /// 중복된 이름이에요!
    public static let warning = MyPageStrings.tr("Localization", "edit_nickname.warning")
    public enum Description {
      /// 로 바꿀래요
      public static let bottom = MyPageStrings.tr("Localization", "edit_nickname.description.bottom")
      /// 닉네임
      public static let top = MyPageStrings.tr("Localization", "edit_nickname.description.top")
    }
  }

  public enum Qna {
    /// FAQ
    public static let faq = MyPageStrings.tr("Localization", "qna.faq")
    /// 1:1 문의
    public static let inquiry = MyPageStrings.tr("Localization", "qna.inquiry")
    /// 문의사항
    public static let title = MyPageStrings.tr("Localization", "qna.title")
  }

  public enum Setting {
    /// 투표 및 댓글 등 활동 알림
    public static let activityNotifictaion = MyPageStrings.tr("Localization", "setting.activity_notifictaion")
    /// 이용 약관
    public static let agreement = MyPageStrings.tr("Localization", "setting.agreement")
    /// 애플 계정 회원
    public static let appleUser = MyPageStrings.tr("Localization", "setting.apple_user")
    /// 구글 계정 회원
    public static let googleUser = MyPageStrings.tr("Localization", "setting.google_user")
    /// 카카오 계정 회원
    public static let kakaoUser = MyPageStrings.tr("Localization", "setting.kakao_user")
    /// 로그아웃
    public static let logout = MyPageStrings.tr("Localization", "setting.logout")
    /// 마케팅 푸시 알림
    public static let marketingNotification = MyPageStrings.tr("Localization", "setting.marketing_notification")
    /// 문의사항
    public static let qna = MyPageStrings.tr("Localization", "setting.qna")
    /// 회원탈퇴
    public static let signout = MyPageStrings.tr("Localization", "setting.signout")
    /// 가슴속 3천원 팀원 소개
    public static let teamInfo = MyPageStrings.tr("Localization", "setting.team_info")
    /// 설정
    public static let title = MyPageStrings.tr("Localization", "setting.title")
    public enum ActivityNotification {
      /// 투표 및 댓글 등 활동 알림 수신 거부되었습니다 🙇‍♀️
      public static let off = MyPageStrings.tr("Localization", "setting.activity_notification.off")
      /// 투표 및 댓글 등 활동 알림 수신 동의되었습니다 👍
      public static let on = MyPageStrings.tr("Localization", "setting.activity_notification.on")
    }
    public enum Ad {
      public enum Boss {
        /// 가슴속 3천원 사장님앱 다운받기
        public static let description = MyPageStrings.tr("Localization", "setting.ad.boss.description")
        /// 직접 사장님 직영점을 운영하고 싶다면?
        public static let title = MyPageStrings.tr("Localization", "setting.ad.boss.title")
      }
      public enum Normal {
        /// 광고소개서 보러 가기
        public static let description = MyPageStrings.tr("Localization", "setting.ad.normal.description")
        /// 가슴속 3천원 앱에 광고하고 싶다면?
        public static let title = MyPageStrings.tr("Localization", "setting.ad.normal.title")
      }
    }
    public enum MarketingNotification {
      /// 마케팅 푸시 알림 수신 거부되었습니다 🙇‍♀️
      public static let off = MyPageStrings.tr("Localization", "setting.marketing_notification.off")
      /// 마케팅 푸시 알림 수신 동의되었습니다 👍
      public static let on = MyPageStrings.tr("Localization", "setting.marketing_notification.on")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension MyPageStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = MyPageResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
