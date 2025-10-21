import Foundation

public struct StoreTagResponse: Decodable, Hashable {
    public let isNew: Bool
    public let hasIssuableCoupon: Bool
}
