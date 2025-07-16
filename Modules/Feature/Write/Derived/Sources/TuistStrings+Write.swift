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
public enum WriteStrings: Sendable {
  /// * 다중선택 가능
  public static let categorySelectionMulti = WriteStrings.tr("Localization", "category_selection_multi")
  /// 카테고리 선택 완료
  public static let categorySelectionOk = WriteStrings.tr("Localization", "category_selection_ok")
  /// 카테고리 선택
  public static let categorySelectionTitle = WriteStrings.tr("Localization", "category_selection_title")
  /// 카드
  public static let storePaymentCard = WriteStrings.tr("Localization", "store_payment_card")
  /// 현금
  public static let storePaymentCash = WriteStrings.tr("Localization", "store_payment_cash")
  /// 계좌이체
  public static let storePaymentTransfer = WriteStrings.tr("Localization", "store_payment_transfer")
  /// 편의점
  public static let storeTypeConvenienceStore = WriteStrings.tr("Localization", "store_type_convenience_store")
  /// 길거리
  public static let storeTypeRoad = WriteStrings.tr("Localization", "store_type_road")
  /// 매장
  public static let storeTypeStore = WriteStrings.tr("Localization", "store_type_store")
  /// 수정
  public static let writeDetailEditLocation = WriteStrings.tr("Localization", "write_detail_edit_location")
  /// 메뉴 카테고리
  public static let writeDetailHeaderCategory = WriteStrings.tr("Localization", "write_detail_header_category")
  /// 출몰시기
  public static let writeDetailHeaderDay = WriteStrings.tr("Localization", "write_detail_header_day")
  /// 전체 삭제
  public static let writeDetailHeaderDeleteAllMenu = WriteStrings.tr("Localization", "write_detail_header_delete_all_menu")
  /// 가게 위치
  public static let writeDetailHeaderLocation = WriteStrings.tr("Localization", "write_detail_header_location")
  /// 가게 이름
  public static let writeDetailHeaderName = WriteStrings.tr("Localization", "write_detail_header_name")
  /// 결제방식
  public static let writeDetailHeaderPaymentType = WriteStrings.tr("Localization", "write_detail_header_payment_type")
  /// 가게형태
  public static let writeDetailHeaderStoreType = WriteStrings.tr("Localization", "write_detail_header_store_type")
  /// 가게 이름
  public static let writeDetailNamePlaceholer = WriteStrings.tr("Localization", "write_detail_name_placeholer")
  /// 가게 등록하기
  public static let writeDetailRegisterButton = WriteStrings.tr("Localization", "write_detail_register_button")
  /// *다중선택 가능
  public static let writeDetailStoreCanSelectMulti = WriteStrings.tr("Localization", "write_detail_store_can_select_multi")
  /// (선택)
  public static let writeDetailStoreOption = WriteStrings.tr("Localization", "write_detail_store_option")
  /// 확인
  public static let writeDetailTimeConfirm = WriteStrings.tr("Localization", "write_detail_time_confirm")
  /// 삭제
  public static let writeDetailTimeDelete = WriteStrings.tr("Localization", "write_detail_time_delete")
  /// a h시
  public static let writeDetailTimeDisplayFormat = WriteStrings.tr("Localization", "write_detail_time_display_format")
  /// HH:mm
  public static let writeDetailTimeFormat = WriteStrings.tr("Localization", "write_detail_time_format")
  /// 부터
  public static let writeDetailTimeFrom = WriteStrings.tr("Localization", "write_detail_time_from")
  /// 오전 9시
  public static let writeDetailTimeFromPlaceholder = WriteStrings.tr("Localization", "write_detail_time_from_placeholder")
  /// 까지
  public static let writeDetailTimeUntil = WriteStrings.tr("Localization", "write_detail_time_until")
  /// 오후 9시
  public static let writeDetailTimeUntilPlaceholder = WriteStrings.tr("Localization", "write_detail_time_until_placeholder")
  /// 가게 제보
  public static let writeDetailTitle = WriteStrings.tr("Localization", "write_detail_title")

  public enum AddressConfirmBottomSheet: Sendable {
  /// 사장님 직영
    public static let bossDirectly = WriteStrings.tr("Localization", "address_confirm_bottom_sheet.boss_directly")
    /// 이 장소가 확실해요
    public static let confirmButton = WriteStrings.tr("Localization", "address_confirm_bottom_sheet.confirm_button")
    /// 외 %d개
    public static func moreFormat(_ p1: Int) -> String {
      return WriteStrings.tr("Localization", "address_confirm_bottom_sheet.more_format",p1)
    }
    /// 근처 가게
    public static let nearStore = WriteStrings.tr("Localization", "address_confirm_bottom_sheet.near_store")
    /// 50m 이내에 이미 등록된 %d개의\n가게가 있어요
    public static func titleFormat(_ p1: Int) -> String {
      return WriteStrings.tr("Localization", "address_confirm_bottom_sheet.title_format",p1)
    }
  }

  public enum BossAppBottomSheet: Sendable {
  /// 아래의 기능을 모두 무료로 만나볼 수 있어요
    public static let description = WriteStrings.tr("Localization", "boss_app_bottom_sheet.description")
    /// 모두 무료로
    public static let greenDescription = WriteStrings.tr("Localization", "boss_app_bottom_sheet.green_description")
    /// 사장님 앱 설치하기
    public static let install = WriteStrings.tr("Localization", "boss_app_bottom_sheet.install")
    /// 사장님 앱을 설치하고\n더 편하게 가게를 관리해 보세요
    public static let title = WriteStrings.tr("Localization", "boss_app_bottom_sheet.title")

    public enum Feature: Sendable {
    /// ✏️ 가게 정보 관리하기
      public static let information = WriteStrings.tr("Localization", "boss_app_bottom_sheet.feature.information")
      /// 🚚 실시간 가게 영업 정보 관리하기
      public static let live = WriteStrings.tr("Localization", "boss_app_bottom_sheet.feature.live")
      /// 💌 단골 손님에게 메세지 보내기
      public static let message = WriteStrings.tr("Localization", "boss_app_bottom_sheet.feature.message")
      /// 📢 가게 소식 공지하기
      public static let notice = WriteStrings.tr("Localization", "boss_app_bottom_sheet.feature.notice")
      /// 🗳️ 리뷰 관리하기
      public static let review = WriteStrings.tr("Localization", "boss_app_bottom_sheet.feature.review")
    }
  }

  public enum WriteAddress: Sendable {
  /// 더 편하게 가게 관리하기
    public static let bossButton = WriteStrings.tr("Localization", "write_address.boss_button")
    /// 👩‍🍳 혹시 제보할 가게의 사장님이라면?
    public static let bossDescription = WriteStrings.tr("Localization", "write_address.boss_description")
    /// 현위치로 가게 제보
    public static let button = WriteStrings.tr("Localization", "write_address.button")
    /// 가게 제보
    public static let title = WriteStrings.tr("Localization", "write_address.title")
  }

  public enum WriteCloseModal: Sendable {
  /// 닫기
    public static let cancel = WriteStrings.tr("Localization", "write_close_modal.cancel")
    /// 지금까지 입력한 정보가 저장되지 않아요.
    public static let description = WriteStrings.tr("Localization", "write_close_modal.description")
    /// 나가기
    public static let dismiss = WriteStrings.tr("Localization", "write_close_modal.dismiss")
    /// 다음에 할까요?
    public static let title = WriteStrings.tr("Localization", "write_close_modal.title")
  }

  public enum WriteDetailInfo: Sendable {
  /// 지금 당장 가게 이름을 알 수 없다면, 근처의 랜드마크와 함께 입력해 보세요.
    public static let description = WriteStrings.tr("Localization", "write_detail_info.description")
    /// 다음
    public static let next = WriteStrings.tr("Localization", "write_detail_info.next")
    /// 가게 정보 입력
    public static let subTitle = WriteStrings.tr("Localization", "write_detail_info.sub_title")
    /// 가게 제보
    public static let title = WriteStrings.tr("Localization", "write_detail_info.title")

    public enum NameTextField: Sendable {
    /// 봉어빵역 2번 출구 삼거리 근처 붕어빵 집
      public static let placeholder = WriteStrings.tr("Localization", "write_detail_info.name_text_field.placeholder")
      /// 가게 이름
      public static let title = WriteStrings.tr("Localization", "write_detail_info.name_text_field.title")
    }

    public enum StoreType: Sendable {
    /// 가게형태
      public static let convience = WriteStrings.tr("Localization", "write_detail_info.store_type.convience")
      /// 가게형태
      public static let foodTruck = WriteStrings.tr("Localization", "write_detail_info.store_type.food_truck")
      /// 가게형태
      public static let road = WriteStrings.tr("Localization", "write_detail_info.store_type.road")
      /// 가게형태
      public static let store = WriteStrings.tr("Localization", "write_detail_info.store_type.store")
      /// 가게형태
      public static let title = WriteStrings.tr("Localization", "write_detail_info.store_type.title")
    }

    public enum Toast: Sendable {
    /// 가게 이름을 입력해주세요.
      public static let needStoreName = WriteStrings.tr("Localization", "write_detail_info.toast.need_store_name")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension WriteStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
