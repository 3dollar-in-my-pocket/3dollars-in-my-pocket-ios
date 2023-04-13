import Foundation

extension Bundle {
    static var admobUnitId: String {
        return Bundle.main.infoDictionary?["ADMOB_UNIT_ID"] as? String ?? ""
    }
    
    static var policyURL: String {
        return Bundle.main.infoDictionary?["URL_POLICY"] as? String ?? ""
    }
    
    static var marketingURL: String {
        return Bundle.main.infoDictionary?["URL_MARKETING"] as? String ?? ""
    }
    
    static var privacyURL: String {
        return Bundle.main.infoDictionary?["URL_PRIVACY"] as? String ?? ""
    }
    
    static var dynamicLinkURL: String {
        return Bundle.main.infoDictionary?["DYNAMIC_LINK_URL"] as? String ?? ""
    }
    
    static var dynamiclinkHost: String {
        return Bundle.main.infoDictionary?["DYNAMICLINK_HOST"] as? String ?? ""
    }
    
    static var bundleId: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    static var androidPackageName: String {
        return Bundle.main.infoDictionary?["ANDROID_PACKAGE_NAME"] as? String ?? ""
    }
    
    static var appstoreId: String {
        return Bundle.main.infoDictionary?["APPSTORE_ID"] as? String ?? ""
    }
}
