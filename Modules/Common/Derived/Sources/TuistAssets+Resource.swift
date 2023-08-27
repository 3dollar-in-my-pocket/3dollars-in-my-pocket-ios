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
public enum ResourceAsset {
  public static let icCheckSolidOff = ResourceImages(name: "ic_check_solid_off")
  public static let icCheckSolidOn = ResourceImages(name: "ic_check_solid_on")
  public static let iconMarkerFocused = ResourceImages(name: "icon_marker_focused")
  public static let iconMarkerUnfocused = ResourceImages(name: "icon_marker_unfocused")
  public static let iconNewBadgeShort = ResourceImages(name: "icon_new_badge_short")
  public static let imageBungeoppang = ResourceImages(name: "image_bungeoppang")
  public static let imageEmptyCategory = ResourceImages(name: "image_empty_category")
  public static let imageNewBadge = ResourceImages(name: "image_new_badge")
  public static let imageSplash = ResourceImages(name: "image_splash")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ResourceImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = ResourceResources.bundle
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

public extension ResourceImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ResourceImages.image property")
  convenience init?(asset: ResourceImages) {
    #if os(iOS) || os(tvOS)
    let bundle = ResourceResources.bundle
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
