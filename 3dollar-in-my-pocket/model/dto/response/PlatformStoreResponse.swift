import Foundation

struct PlatformStoreResponse: Decodable {
    let categories: [PlatformStoreCategoryResponse]
    let storeId: String
    let storeName: String
    let storeType: String
}
