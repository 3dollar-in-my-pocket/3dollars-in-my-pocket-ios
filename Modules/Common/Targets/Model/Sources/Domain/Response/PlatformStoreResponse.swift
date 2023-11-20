import Foundation

public struct PlatformStoreResponse: Decodable {
    public let storeType: String
    public let storeId: String
    public let account: AccountResponse?
    public let storeName: String
    public let address: AddressResponse?
    public let location: LocationResponse?
    public let categories: [PlatformStoreCategoryResponse]
    public let isDeleted: Bool
    public let createdAt: String?
    public let updatedAt: String?
}
