// swiftlint:disable:this file_name
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
#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - Asset Catalogs

public enum MyPageAsset: Sendable {
  public static let bgCloud = MyPageImages(name: "bg_cloud")
  public static let iconApple = MyPageImages(name: "icon_apple")
  public static let iconDelete = MyPageImages(name: "icon_delete")
  public static let iconGoogle = MyPageImages(name: "icon_google")
  public static let iconInsta = MyPageImages(name: "icon_insta")
  public static let iconKakao = MyPageImages(name: "icon_kakao")
  public static let iconNewBadgeShort = MyPageImages(name: "icon_new_badge_short")
  public static let imageBannerBoss = MyPageImages(name: "image_banner_boss")
  public static let imageBannerNormal = MyPageImages(name: "image_banner_normal")
  public static let imageBungeoppang = MyPageImages(name: "image_bungeoppang")
  public static let imageEmpty = MyPageImages(name: "image_empty")
  public static let imageLogo = MyPageImages(name: "image_logo")
}

// MARK: - Implementation Details

public struct MyPageImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
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

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: MyPageImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: MyPageImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: MyPageImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
