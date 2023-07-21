import Foundation

private class BundleProvider { }

extension Bundle {
    static var frameworkBundle: Bundle {
        return Bundle(for: BundleProvider.self)
    }
}
