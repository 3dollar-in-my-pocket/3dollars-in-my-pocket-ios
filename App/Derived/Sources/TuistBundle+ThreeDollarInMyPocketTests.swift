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
/// Since three-dollar-in-my-pocketTests is a unit tests, the bundle for classes within this module can be used directly.
    static let module = Bundle(for: BundleFinder.self)
}
// MARK: - Objective-C Bundle Accessor
@objc
public class ThreeDollarInMyPocketTestsResources: NSObject {
@objc public class var bundle: Bundle {
    return .module
}
}
// swiftformat:enable all
// swiftlint:enable all