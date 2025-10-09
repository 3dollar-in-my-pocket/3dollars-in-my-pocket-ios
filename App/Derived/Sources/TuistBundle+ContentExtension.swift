// periphery:ignore:all
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if hasFeature(InternalImportsByDefault)
public import Foundation
#else
import Foundation
#endif
// MARK: - Swift Bundle Accessor for Frameworks
private class BundleFinder {}
extension Foundation.Bundle {
/// Since content-extension is a app extension, the bundle for classes within this module can be used directly.
    static let module = Bundle(for: BundleFinder.self)
}
// MARK: - Objective-C Bundle Accessor
@objc
public class ContentExtensionResources: NSObject {
@objc public class var bundle: Bundle {
    return .module
}
}
// swiftformat:enable all
// swiftlint:enable all