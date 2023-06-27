import Foundation

public struct FetchAroundStoreInput: Encodable {
    let distanceM: Double?
    let categoryIds: [String]?
    let targetStores: [String]
    let sortType: String? // DISTANCE_ASC, LATEST
    let filterCertifiedStores: Bool?
    let size: Int?
    let cursor: String?
    let mapLatitude: Double
    let mapLongitude: Double
}
