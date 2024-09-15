import Foundation

public struct UserStoreResponse: Decodable {
    public let storeId: Int
    public let isOwner: Bool
    public let name: String
    public let salesType: SalesType?
    public let rating: Double
    public let location: LocationResponse
    public let address: AddressResponse
    public let categories: [StoreFoodCategoryResponse]
    public let appearanceDays: [AppearanceDay]
    public let openingHours: StoreOpeningHoursResponse?
    public let paymentMethods: [PaymentMethod]
    public let menus: [UserStoreMenuResponse]
    public let isDeleted: Bool
    public let activitiesStatus: ActivitiesStatus
    public let createdAt: String
    public let updatedAt: String
}
