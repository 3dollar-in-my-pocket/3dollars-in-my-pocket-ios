import Foundation

public struct ContentListStoreCouponSimpleResponse: Decodable {
    public let contents: [StoreCouponSimpleResponse]
}

public struct StoreCouponSimpleResponse: Decodable {
    public let couponId: String
    public let name: String
    public let validityPeriod: DateTimeIntervalResponse
    public let issued: StoreCouponIssuedResponse?
}
