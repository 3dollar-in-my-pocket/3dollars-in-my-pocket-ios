// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum ThreeDollarInMyPocketAsset {
  public enum Assets {
    public static let bgCloud = ThreeDollarInMyPocketImages(name: "bg_cloud")
    public static let bgCloudMyPage = ThreeDollarInMyPocketImages(name: "bg_cloud_my_page")
    public static let icApple = ThreeDollarInMyPocketImages(name: "ic_apple")
    public static let icArrowBottom = ThreeDollarInMyPocketImages(name: "ic_arrow_bottom")
    public static let icArrowBottomBlack = ThreeDollarInMyPocketImages(name: "ic_arrow_bottom_black")
    public static let icBack = ThreeDollarInMyPocketImages(name: "ic_back")
    public static let icBackBlack = ThreeDollarInMyPocketImages(name: "ic_back_black")
    public static let icBackWhite = ThreeDollarInMyPocketImages(name: "ic_back_white")
    public static let icBedge = ThreeDollarInMyPocketImages(name: "ic_bedge")
    public static let icBookmarkOff = ThreeDollarInMyPocketImages(name: "ic_bookmark_off")
    public static let icBookmarkOn = ThreeDollarInMyPocketImages(name: "ic_bookmark_on")
    public static let icCheck = ThreeDollarInMyPocketImages(name: "ic_check")
    public static let icCheckCircleOff = ThreeDollarInMyPocketImages(name: "ic_check_circle_off")
    public static let icCheckCircleOn = ThreeDollarInMyPocketImages(name: "ic_check_circle_on")
    public static let icCheckLineOff = ThreeDollarInMyPocketImages(name: "ic_check_line_off")
    public static let icCheckLineOn = ThreeDollarInMyPocketImages(name: "ic_check_line_on")
    public static let icCheckOff = ThreeDollarInMyPocketImages(name: "ic_check_off")
    public static let icCheckOffGreen = ThreeDollarInMyPocketImages(name: "ic_check_off_green")
    public static let icCheckOn = ThreeDollarInMyPocketImages(name: "ic_check_on")
    public static let icCheckOnGreen = ThreeDollarInMyPocketImages(name: "ic_check_on_green")
    public static let icCheckSolidOff = ThreeDollarInMyPocketImages(name: "ic_check_solid_off")
    public static let icCheckSolidOn = ThreeDollarInMyPocketImages(name: "ic_check_solid_on")
    public static let icClose = ThreeDollarInMyPocketImages(name: "ic_close")
    public static let icClose24 = ThreeDollarInMyPocketImages(name: "ic_close_24")
    public static let icCloseWhite = ThreeDollarInMyPocketImages(name: "ic_close_white")
    public static let icCloseWhiteBackground = ThreeDollarInMyPocketImages(name: "ic_close_white_background")
    public static let icDeleteCategory = ThreeDollarInMyPocketImages(name: "ic_delete_category")
    public static let icDeleteSmall = ThreeDollarInMyPocketImages(name: "ic_delete_small")
    public static let icDest = ThreeDollarInMyPocketImages(name: "ic_dest")
    public static let icDown = ThreeDollarInMyPocketImages(name: "ic_down")
    public static let icEdit = ThreeDollarInMyPocketImages(name: "ic_edit")
    public static let icFoodTruck = ThreeDollarInMyPocketImages(name: "ic_food_truck")
    public static let icFrontWhite = ThreeDollarInMyPocketImages(name: "ic_front_white")
    public static let icFwd = ThreeDollarInMyPocketImages(name: "ic_fwd")
    public static let icHome = ThreeDollarInMyPocketImages(name: "ic_home")
    public static let icInfo = ThreeDollarInMyPocketImages(name: "ic_info")
    public static let icKakao = ThreeDollarInMyPocketImages(name: "ic_kakao")
    public static let icLocationGreen = ThreeDollarInMyPocketImages(name: "ic_location_green")
    public static let icLocationPink = ThreeDollarInMyPocketImages(name: "ic_location_pink")
    public static let icMarker = ThreeDollarInMyPocketImages(name: "ic_marker")
    public static let icMarkerBossClosed = ThreeDollarInMyPocketImages(name: "ic_marker_boss_closed")
    public static let icMarkerBossClosedSelected = ThreeDollarInMyPocketImages(name: "ic_marker_boss_closed_selected")
    public static let icMarkerBossOpenSelected = ThreeDollarInMyPocketImages(name: "ic_marker_boss_open_selected")
    public static let icMarkerStoreOff = ThreeDollarInMyPocketImages(name: "ic_marker_store_off")
    public static let icMarkerStoreOn = ThreeDollarInMyPocketImages(name: "ic_marker_store_on")
    public static let icMore = ThreeDollarInMyPocketImages(name: "ic_more")
    public static let icMoreHorizontal = ThreeDollarInMyPocketImages(name: "ic_more_horizontal")
    public static let icMy = ThreeDollarInMyPocketImages(name: "ic_my")
    public static let icNear = ThreeDollarInMyPocketImages(name: "ic_near")
    public static let icNearFilledGreen = ThreeDollarInMyPocketImages(name: "ic_near_filled_green")
    public static let icNearFilledPink = ThreeDollarInMyPocketImages(name: "ic_near_filled_pink")
    public static let icNearWhite = ThreeDollarInMyPocketImages(name: "ic_near_white")
    public static let icPencil = ThreeDollarInMyPocketImages(name: "ic_pencil")
    public static let icPlusBlack = ThreeDollarInMyPocketImages(name: "ic_plus_black")
    public static let icPlusPink = ThreeDollarInMyPocketImages(name: "ic_plus_pink")
    public static let icPush = ThreeDollarInMyPocketImages(name: "ic_push")
    public static let icRadioOff = ThreeDollarInMyPocketImages(name: "ic_radio_off")
    public static let icRadioOn = ThreeDollarInMyPocketImages(name: "ic_radio_on")
    public static let icReviewGreen = ThreeDollarInMyPocketImages(name: "ic_review_green")
    public static let icReviewWhite = ThreeDollarInMyPocketImages(name: "ic_review_white")
    public static let icRightArrow = ThreeDollarInMyPocketImages(name: "ic_right_arrow")
    public static let icSearch = ThreeDollarInMyPocketImages(name: "ic_search")
    public static let icSetting = ThreeDollarInMyPocketImages(name: "ic_setting")
    public static let icSettingApple = ThreeDollarInMyPocketImages(name: "ic_setting_apple")
    public static let icSettingKakao = ThreeDollarInMyPocketImages(name: "ic_setting_kakao")
    public static let icSettingMessage = ThreeDollarInMyPocketImages(name: "ic_setting_message")
    public static let icSettingNotice = ThreeDollarInMyPocketImages(name: "ic_setting_notice")
    public static let icShare = ThreeDollarInMyPocketImages(name: "ic_share")
    public static let icStar = ThreeDollarInMyPocketImages(name: "ic_star")
    public static let icStar32Off = ThreeDollarInMyPocketImages(name: "ic_star_32_off")
    public static let icStar32On = ThreeDollarInMyPocketImages(name: "ic_star_32_on")
    public static let icStarGray = ThreeDollarInMyPocketImages(name: "ic_star_gray")
    public static let icStarGreen = ThreeDollarInMyPocketImages(name: "ic_star_green")
    public static let icStarOff = ThreeDollarInMyPocketImages(name: "ic_star_off")
    public static let icStarOn = ThreeDollarInMyPocketImages(name: "ic_star_on")
    public static let icStarWhite = ThreeDollarInMyPocketImages(name: "ic_star_white")
    public static let icStreetFood = ThreeDollarInMyPocketImages(name: "ic_street_food")
    public static let icSync = ThreeDollarInMyPocketImages(name: "ic_sync")
    public static let icTrash = ThreeDollarInMyPocketImages(name: "ic_trash")
    public static let icWarning = ThreeDollarInMyPocketImages(name: "ic_warning")
    public static let icWarningWhite = ThreeDollarInMyPocketImages(name: "ic_warning_white")
    public static let icWrite = ThreeDollarInMyPocketImages(name: "ic_write")
    public static let img32BungeoppangOff = ThreeDollarInMyPocketImages(name: "img_32_bungeoppang_off")
    public static let img32BungeoppangOn = ThreeDollarInMyPocketImages(name: "img_32_bungeoppang_on")
    public static let img32DalgonaOff = ThreeDollarInMyPocketImages(name: "img_32_dalgona_off")
    public static let img32DalgonaOn = ThreeDollarInMyPocketImages(name: "img_32_dalgona_on")
    public static let img32EomukOff = ThreeDollarInMyPocketImages(name: "img_32_eomuk_off")
    public static let img32EomukOn = ThreeDollarInMyPocketImages(name: "img_32_eomuk_on")
    public static let img32GukwappangOff = ThreeDollarInMyPocketImages(name: "img_32_gukwappang_off")
    public static let img32GukwappangOn = ThreeDollarInMyPocketImages(name: "img_32_gukwappang_on")
    public static let img32GungogumaOff = ThreeDollarInMyPocketImages(name: "img_32_gungoguma_off")
    public static let img32GungogumaOn = ThreeDollarInMyPocketImages(name: "img_32_gungoguma_on")
    public static let img32GunoksusuOff = ThreeDollarInMyPocketImages(name: "img_32_gunoksusu_off")
    public static let img32GunoksusuOn = ThreeDollarInMyPocketImages(name: "img_32_gunoksusu_on")
    public static let img32GyeranppangOff = ThreeDollarInMyPocketImages(name: "img_32_gyeranppang_off")
    public static let img32GyeranppangOn = ThreeDollarInMyPocketImages(name: "img_32_gyeranppang_on")
    public static let img32HotteokOff = ThreeDollarInMyPocketImages(name: "img_32_hotteok_off")
    public static let img32HotteokOn = ThreeDollarInMyPocketImages(name: "img_32_hotteok_on")
    public static let img32KkochiOff = ThreeDollarInMyPocketImages(name: "img_32_kkochi_off")
    public static let img32KkochiOn = ThreeDollarInMyPocketImages(name: "img_32_kkochi_on")
    public static let img32SundaeOff = ThreeDollarInMyPocketImages(name: "img_32_sundae_off")
    public static let img32SundaeOn = ThreeDollarInMyPocketImages(name: "img_32_sundae_on")
    public static let img32TakoyakiOff = ThreeDollarInMyPocketImages(name: "img_32_takoyaki_off")
    public static let img32TakoyakiOn = ThreeDollarInMyPocketImages(name: "img_32_takoyaki_on")
    public static let img32ToastOff = ThreeDollarInMyPocketImages(name: "img_32_toast_off")
    public static let img32ToastOn = ThreeDollarInMyPocketImages(name: "img_32_toast_on")
    public static let img32TtangkongppangOff = ThreeDollarInMyPocketImages(name: "img_32_ttangkongppang_off")
    public static let img32TtangkongppangOn = ThreeDollarInMyPocketImages(name: "img_32_ttangkongppang_on")
    public static let img32TteokbokkiOff = ThreeDollarInMyPocketImages(name: "img_32_tteokbokki_off")
    public static let img32TteokbokkiOn = ThreeDollarInMyPocketImages(name: "img_32_tteokbokki_on")
    public static let img32WaffleOff = ThreeDollarInMyPocketImages(name: "img_32_waffle_off")
    public static let img32WaffleOn = ThreeDollarInMyPocketImages(name: "img_32_waffle_on")
    public static let img60Bungeoppang = ThreeDollarInMyPocketImages(name: "img_60_bungeoppang")
    public static let img60Dalgona = ThreeDollarInMyPocketImages(name: "img_60_dalgona")
    public static let img60Eomuk = ThreeDollarInMyPocketImages(name: "img_60_eomuk")
    public static let img60Gukwappang = ThreeDollarInMyPocketImages(name: "img_60_gukwappang")
    public static let img60Gungoguma = ThreeDollarInMyPocketImages(name: "img_60_gungoguma")
    public static let img60Gunoksusu = ThreeDollarInMyPocketImages(name: "img_60_gunoksusu")
    public static let img60Gyeranppang = ThreeDollarInMyPocketImages(name: "img_60_gyeranppang")
    public static let img60Hotteok = ThreeDollarInMyPocketImages(name: "img_60_hotteok")
    public static let img60Kkochi = ThreeDollarInMyPocketImages(name: "img_60_kkochi")
    public static let img60Sundae = ThreeDollarInMyPocketImages(name: "img_60_sundae")
    public static let img60Takoyaki = ThreeDollarInMyPocketImages(name: "img_60_takoyaki")
    public static let img60Toast = ThreeDollarInMyPocketImages(name: "img_60_toast")
    public static let img60Ttangkongppang = ThreeDollarInMyPocketImages(name: "img_60_ttangkongppang")
    public static let img60Tteokbokki = ThreeDollarInMyPocketImages(name: "img_60_tteokbokki")
    public static let img60Waffle = ThreeDollarInMyPocketImages(name: "img_60_waffle")
    public static let imgAnonymous = ThreeDollarInMyPocketImages(name: "img_anonymous")
    public static let imgBedge = ThreeDollarInMyPocketImages(name: "img_bedge")
    public static let imgBedgeGray = ThreeDollarInMyPocketImages(name: "img_bedge_gray")
    public static let imgBossEmptyMenu = ThreeDollarInMyPocketImages(name: "img_boss_empty_menu")
    public static let imgDetailBungeoppang = ThreeDollarInMyPocketImages(name: "img_detail_bungeoppang")
    public static let imgDistanceIndicator = ThreeDollarInMyPocketImages(name: "img_distance_indicator")
    public static let imgDivider = ThreeDollarInMyPocketImages(name: "img_divider")
    public static let imgEmpty = ThreeDollarInMyPocketImages(name: "img_empty")
    public static let imgEmptyHome = ThreeDollarInMyPocketImages(name: "img_empty_home")
    public static let imgEmptyMy = ThreeDollarInMyPocketImages(name: "img_empty_my")
    public static let imgEmptyMyRegisteredStoreBackground = ThreeDollarInMyPocketImages(name: "img_empty_my_registered_store_background")
    public static let imgEmptyMyReviewBackground = ThreeDollarInMyPocketImages(name: "img_empty_my_review_background")
    public static let imgEmptyMyVisitHistoryBackground = ThreeDollarInMyPocketImages(name: "img_empty_my_visit_history_background")
    public static let imgExist = ThreeDollarInMyPocketImages(name: "img_exist")
    public static let imgExistEmpty = ThreeDollarInMyPocketImages(name: "img_exist_empty")
    public static let imgFaceFail = ThreeDollarInMyPocketImages(name: "img_face_fail")
    public static let imgFaceSuccess = ThreeDollarInMyPocketImages(name: "img_face_success")
    public static let imgMyPageEmpty = ThreeDollarInMyPocketImages(name: "img_my_page_empty")
    public static let imgNotExist = ThreeDollarInMyPocketImages(name: "img_not_exist")
    public static let imgNotExistEmpty = ThreeDollarInMyPocketImages(name: "img_not_exist_empty")
    public static let imgStartOffDisable = ThreeDollarInMyPocketImages(name: "img_start_off_disable")
    public static let imgStartOffNormal = ThreeDollarInMyPocketImages(name: "img_start_off_normal")
    public static let imgTootipFinger = ThreeDollarInMyPocketImages(name: "img_tootip_finger")
    public static let imgTopIndicator = ThreeDollarInMyPocketImages(name: "img_top_indicator")
    public static let imgVisitFail = ThreeDollarInMyPocketImages(name: "img_visit_fail")
    public static let imgVisitSuccess = ThreeDollarInMyPocketImages(name: "img_visit_success")
    public static let imgSigninBackground = ThreeDollarInMyPocketImages(name: "img_signin_background")
  }
  public enum Colors {
    public static let black = ThreeDollarInMyPocketColors(name: "black")
    public static let gray0 = ThreeDollarInMyPocketColors(name: "gray-0")
    public static let gray1 = ThreeDollarInMyPocketColors(name: "gray-1")
    public static let gray10 = ThreeDollarInMyPocketColors(name: "gray-10")
    public static let gray100 = ThreeDollarInMyPocketColors(name: "gray-100")
    public static let gray20 = ThreeDollarInMyPocketColors(name: "gray-20")
    public static let gray30 = ThreeDollarInMyPocketColors(name: "gray-30")
    public static let gray40 = ThreeDollarInMyPocketColors(name: "gray-40")
    public static let gray5 = ThreeDollarInMyPocketColors(name: "gray-5")
    public static let gray50 = ThreeDollarInMyPocketColors(name: "gray-50")
    public static let gray60 = ThreeDollarInMyPocketColors(name: "gray-60")
    public static let gray70 = ThreeDollarInMyPocketColors(name: "gray-70")
    public static let gray80 = ThreeDollarInMyPocketColors(name: "gray-80")
    public static let gray90 = ThreeDollarInMyPocketColors(name: "gray-90")
    public static let gray95 = ThreeDollarInMyPocketColors(name: "gray-95")
    public static let green = ThreeDollarInMyPocketColors(name: "green")
    public static let kakaoYellow = ThreeDollarInMyPocketColors(name: "kakao-yellow")
    public static let pink = ThreeDollarInMyPocketColors(name: "pink")
    public static let red = ThreeDollarInMyPocketColors(name: "red")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ThreeDollarInMyPocketColors {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ThreeDollarInMyPocketColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ThreeDollarInMyPocketColors) {
    let bundle = ThreeDollarInMyPocketResources.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct ThreeDollarInMyPocketImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = ThreeDollarInMyPocketResources.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

public extension ThreeDollarInMyPocketImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ThreeDollarInMyPocketImages.image property")
  convenience init?(asset: ThreeDollarInMyPocketImages) {
    #if os(iOS) || os(tvOS)
    let bundle = ThreeDollarInMyPocketResources.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:enable all
// swiftformat:enable all
