import Foundation

public struct StoreVisitCountResponse: Decodable {
    public let existsCounts: Int
    public let notExistsCounts: Int
    public let isCertified: Bool
}
