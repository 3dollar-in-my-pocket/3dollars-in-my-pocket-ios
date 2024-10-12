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
public enum MembershipAsset {
  public static let icArrowDown = MembershipImages(name: "ic_arrow_down")
  public static let icCheckSolidOff = MembershipImages(name: "ic_check_solid_off")
  public static let icCheckSolidOn = MembershipImages(name: "ic_check_solid_on")
  public static let icClose = MembershipImages(name: "ic_close")
  public static let imageBungeoppang = MembershipImages(name: "image_bungeoppang")
  public static let imageSplash = MembershipImages(name: "image_splash")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct MembershipImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = MembershipResources.bundle
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

public extension MembershipImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the MembershipImages.image property")
  convenience init?(asset: MembershipImages) {
    #if os(iOS) || os(tvOS)
    let bundle = MembershipResources.bundle
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
