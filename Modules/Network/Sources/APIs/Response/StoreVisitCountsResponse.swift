import Foundation

public struct StoreVisitCountsResponse: Decodable {
    let existsCounts: Int?
    let notExistsCounts: Int?
    let isCertified: Bool
}
