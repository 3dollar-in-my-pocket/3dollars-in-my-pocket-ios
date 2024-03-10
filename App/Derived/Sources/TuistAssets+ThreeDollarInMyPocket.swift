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
    public static let icBackWhite = ThreeDollarInMyPocketImages(name: "ic_back_white")
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
