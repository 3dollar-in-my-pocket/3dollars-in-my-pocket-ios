import Foundation

public struct StoreDetailInfo: Hashable {
    public let lastUpdated: String
    public let salesType: SalesType?
    public let appearanceDays: [AppearanceDay]
    public let openingHours: StoreDetailOpeningHours?
    public let paymentMethods: [PaymentMethod]
}
