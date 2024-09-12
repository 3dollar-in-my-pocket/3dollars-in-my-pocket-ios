import Foundation

public struct StoreVisitCountsResponse: Decodable, Hashable {
    public let existsCounts: Int?
    public let notExistsCounts: Int?
    public let isCertified: Bool
}
