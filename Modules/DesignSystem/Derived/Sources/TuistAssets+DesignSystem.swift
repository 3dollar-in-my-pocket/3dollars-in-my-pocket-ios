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
  public enum Colors {
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
  public enum Icons {
    public static let apple = DesignSystemImages(name: "apple")
    public static let arrowLeft = DesignSystemImages(name: "arrow.left")
    public static let arrowRight = DesignSystemImages(name: "arrow.right")
    public static let bookmarkLine = DesignSystemImages(name: "bookmark.line")
    public static let bookmarkSolid = DesignSystemImages(name: "bookmark.solid")
    public static let category = DesignSystemImages(name: "category")
    public static let change = DesignSystemImages(name: "change")
    public static let checkBoxOff = DesignSystemImages(name: "check.box.off")
    public static let checkBoxOn = DesignSystemImages(name: "check.box.on")
    public static let check = DesignSystemImages(name: "check")
    public static let checkRoundOff = DesignSystemImages(name: "check.round.off")
    public static let checkRoundOn = DesignSystemImages(name: "check.round.on")
    public static let close = DesignSystemImages(name: "close")
    public static let communityLine = DesignSystemImages(name: "community.line")
    public static let communitySolid = DesignSystemImages(name: "community.solid")
    public static let copy = DesignSystemImages(name: "copy")
    public static let delete = DesignSystemImages(name: "delete")
    public static let deleteX = DesignSystemImages(name: "delete_x")
    public static let deletion = DesignSystemImages(name: "deletion")
    public static let faceSad = DesignSystemImages(name: "face.sad")
    public static let faceSmile = DesignSystemImages(name: "face.smile")
    public static let fireLine = DesignSystemImages(name: "fire.line")
    public static let fireSolid = DesignSystemImages(name: "fire.solid")
    public static let heartFill = DesignSystemImages(name: "heart.fill")
    public static let homeLine = DesignSystemImages(name: "home.line")
    public static let homeSolid = DesignSystemImages(name: "home.solid")
    public static let infomation = DesignSystemImages(name: "infomation")
    public static let kakao = DesignSystemImages(name: "kakao")
    public static let link = DesignSystemImages(name: "link")
    public static let list = DesignSystemImages(name: "list")
    public static let locationCurrent = DesignSystemImages(name: "location.current")
    public static let locationLine = DesignSystemImages(name: "location.line")
    public static let locationSolid = DesignSystemImages(name: "location.solid")
    public static let map = DesignSystemImages(name: "map")
    public static let mappinUnfocused = DesignSystemImages(name: "mappin.unfocused")
    public static let markerFocuesd = DesignSystemImages(name: "marker.focuesd")
    public static let markerUnfocused = DesignSystemImages(name: "marker.unfocused")
    public static let myLine = DesignSystemImages(name: "my.line")
    public static let mySolid = DesignSystemImages(name: "my.solid")
    public static let plus = DesignSystemImages(name: "plus")
    public static let review = DesignSystemImages(name: "review")
    public static let search = DesignSystemImages(name: "search")
    public static let setting = DesignSystemImages(name: "setting")
    public static let share = DesignSystemImages(name: "share")
    public static let starLine = DesignSystemImages(name: "star.line")
    public static let starSolid = DesignSystemImages(name: "star.solid")
    public static let writeLine = DesignSystemImages(name: "write.line")
    public static let writeSolid = DesignSystemImages(name: "write.solid")
    public static let zoom = DesignSystemImages(name: "zoom")
  }
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

public struct DesignSystemImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = DesignSystemResources.bundle
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

public extension DesignSystemImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the DesignSystemImages.image property")
  convenience init?(asset: DesignSystemImages) {
    #if os(iOS) || os(tvOS)
    let bundle = DesignSystemResources.bundle
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
