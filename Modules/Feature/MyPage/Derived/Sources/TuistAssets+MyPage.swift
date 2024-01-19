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
public enum MyPageAsset {
  public static let bgCloud = MyPageImages(name: "bg_cloud")
  public static let iconApple = MyPageImages(name: "icon_apple")
  public static let iconGoogle = MyPageImages(name: "icon_google")
  public static let iconKakao = MyPageImages(name: "icon_kakao")
  public static let imageBannerBoss = MyPageImages(name: "image_banner_boss")
  public static let imageBannerNormal = MyPageImages(name: "image_banner_normal")
  public static let imageBungeoppang = MyPageImages(name: "image_bungeoppang")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct MyPageImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = MyPageResources.bundle
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

public extension MyPageImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the MyPageImages.image property")
  convenience init?(asset: MyPageImages) {
    #if os(iOS) || os(tvOS)
    let bundle = MyPageResources.bundle
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
