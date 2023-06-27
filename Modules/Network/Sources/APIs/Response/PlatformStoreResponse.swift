import Foundation

public struct PlatformStoreResponse: Decodable {
    let storeType: String
    let storeId: String
    let account: AccountResponse?
    let storeName: String
    let address: AddressResponse?
    let location: LocationResponse?
    let categories: [PlatformStoreCategoryResponse]
    let isDeleted: Bool
    let createdAt: String?
    let updatedAt: String?
}
