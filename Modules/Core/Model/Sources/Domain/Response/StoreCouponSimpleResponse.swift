import Foundation

public struct ContentListStoreCouponSimpleResponse: Decodable {
    public let contents: [StoreCouponSimpleResponse]
}

public struct StoreCouponSimpleResponse: Decodable {
    public let couponId: String
    public let name: String
    public let validityPeriod: DateTimeIntervalResponse
    public let issued: StoreCouponIssuedResponse?
    public let store: StoreResponse?
}

extension StoreCouponSimpleResponse: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(couponId)
    }
    
    public static func == (lhs: StoreCouponSimpleResponse, rhs: StoreCouponSimpleResponse) -> Bool {
        return lhs.couponId == rhs.couponId
    }
}
