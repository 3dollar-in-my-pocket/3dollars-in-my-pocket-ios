// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum WriteStrings {
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
  /// 맛집 위치는 바로 여기!
  public static let writeAddressBottomTitle = WriteStrings.tr("Localization", "write_address_bottom_title")
  /// 이 위치로 하기
  public static let writeAddressButton = WriteStrings.tr("Localization", "write_address_button")
  /// 중복된 가게 제보인지 확인해 주세요.
  public static let writeAddressConfirmPopupDescription = WriteStrings.tr("Localization", "write_address_confirm_popup_description")
  /// 여기가 확실해요
  public static let writeAddressConfirmPopupOk = WriteStrings.tr("Localization", "write_address_confirm_popup_ok")
  /// 10m이내에 이미 제보된\n가게가 있어요! 
  public static let writeAddressConfirmPopupTitle = WriteStrings.tr("Localization", "write_address_confirm_popup_title")
  /// 가게 제보
  public static let writeAddressTitle = WriteStrings.tr("Localization", "write_address_title")
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
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension WriteStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = WriteResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
