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
}
