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
public enum HomeAsset {
  public static let iconMarkerFocused = HomeImages(name: "icon_marker_focused")
  public static let iconMarkerUnfocused = HomeImages(name: "icon_marker_unfocused")
  public static let iconNewBadgeShort = HomeImages(name: "icon_new_badge_short")
  public static let imageEmptyCategory = HomeImages(name: "image_empty_category")
  public static let imageEmptyList = HomeImages(name: "image_empty_list")
  public static let imageNewBadge = HomeImages(name: "image_new_badge")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct HomeImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = HomeResources.bundle
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

public extension HomeImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the HomeImages.image property")
  convenience init?(asset: HomeImages) {
    #if os(iOS) || os(tvOS)
    let bundle = HomeResources.bundle
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
