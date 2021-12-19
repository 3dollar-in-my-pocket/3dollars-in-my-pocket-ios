import Foundation

extension Bundle {
    static var admobUnitId: String {
        return Bundle.main.infoDictionary?["ADMOB_UNIT_ID"] as? String ?? ""
    }
}
