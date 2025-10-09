import Model

public struct GetMyIssuedCouponsInput: Encodable {
    public let cursor: String?
    public let size: Int?
    public let sortBy: String
    public let statuses: [String]
    
    public init(
        cursor: String? = nil,
        size: Int? = 20,
        sortBy: String = "LATEST",
        statuses: [String] = ["ISSUED", "USED", "EXPIRED"]
    ) {
        self.cursor = cursor
        self.size = size
        self.sortBy = sortBy
        self.statuses = statuses
    }
}


enum CouponApi {
    case getMyIssuedCoupons(input: GetMyIssuedCouponsInput)
    case issueStoreCoupon(storeId: String, couponId: String)
    case useIssuedCoupon(issuedKey: String)
}

extension CouponApi: RequestType {
    var param: Encodable? {
        switch self {
        case .getMyIssuedCoupons(let input):
            return input
        case .issueStoreCoupon:
            return nil
        case .useIssuedCoupon:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .getMyIssuedCoupons:
            return .get
        case .issueStoreCoupon:
            return .post
        case .useIssuedCoupon:
            return .put
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .getMyIssuedCoupons:
            return .location
        case .issueStoreCoupon:
            return .json
        case .useIssuedCoupon:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .getMyIssuedCoupons:
            return "/api/v1/my/issued-coupons"
        case .issueStoreCoupon(let storeId, let couponId):
            return "/api/v1/store/\(storeId)/coupon/\(couponId)/issue"
        case .useIssuedCoupon(let issuedKey):
            return "/api/v1/issued-coupon/\(issuedKey)/use"
        }
    }
}
