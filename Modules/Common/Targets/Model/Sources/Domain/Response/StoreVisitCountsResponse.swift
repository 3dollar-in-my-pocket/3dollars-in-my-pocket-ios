import Foundation

public struct StoreVisitCountsResponse: Decodable {
    public let existsCounts: Int?
    public let notExistsCounts: Int?
    public let isCertified: Bool
}
