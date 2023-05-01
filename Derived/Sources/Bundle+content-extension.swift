// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
import Foundation

// MARK: - Swift Bundle Accessor

private class BundleFinder {}

extension Foundation.Bundle {
    /// Since content-extension is a app extension, the bundle containing the resources is copied into the final product.
    static var module: Bundle = {
        return Bundle(for: BundleFinder.self)
    }()
}

// MARK: - Objective-C Bundle Accessor

@objc
public class ContentExtensionResources: NSObject {
   @objc public class var bundle: Bundle {
         return .module
   }
}
// swiftlint:enable all
// swiftformat:enable all
