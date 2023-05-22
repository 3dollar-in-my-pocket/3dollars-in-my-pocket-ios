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
public enum DesignSystemAsset {
  public static let gray0 = DesignSystemColors(name: "gray0")
  public static let gray10 = DesignSystemColors(name: "gray10")
  public static let gray100 = DesignSystemColors(name: "gray100")
  public static let gray20 = DesignSystemColors(name: "gray20")
  public static let gray30 = DesignSystemColors(name: "gray30")
  public static let gray40 = DesignSystemColors(name: "gray40")
  public static let gray50 = DesignSystemColors(name: "gray50")
  public static let gray60 = DesignSystemColors(name: "gray60")
  public static let gray70 = DesignSystemColors(name: "gray70")
  public static let gray80 = DesignSystemColors(name: "gray80")
  public static let gray90 = DesignSystemColors(name: "gray90")
  public static let gray95 = DesignSystemColors(name: "gray95")
  public static let green100 = DesignSystemColors(name: "green100")
  public static let green200 = DesignSystemColors(name: "green200")
  public static let green300 = DesignSystemColors(name: "green300")
  public static let green400 = DesignSystemColors(name: "green400")
  public static let green500 = DesignSystemColors(name: "green500")
  public static let mainGreen = DesignSystemColors(name: "main.green")
  public static let mainPink = DesignSystemColors(name: "main.pink")
  public static let mainRed = DesignSystemColors(name: "main.red")
  public static let pink100 = DesignSystemColors(name: "pink100")
  public static let pink200 = DesignSystemColors(name: "pink200")
  public static let pink300 = DesignSystemColors(name: "pink300")
  public static let pink400 = DesignSystemColors(name: "pink400")
  public static let pink500 = DesignSystemColors(name: "pink500")
  public static let systemBlack = DesignSystemColors(name: "system.black")
  public static let systemWhite = DesignSystemColors(name: "system.white")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class DesignSystemColors {
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

public extension DesignSystemColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: DesignSystemColors) {
    let bundle = DesignSystemResources.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:enable all
// swiftformat:enable all
