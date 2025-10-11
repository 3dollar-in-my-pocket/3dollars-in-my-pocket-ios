public struct MyPageStore {
    public let store: PlatformStore
    public let visitInfo: VisitInfo?
    public let coupon: StoreCouponSimpleResponse?

    public init(storeResponse: StoreResponse, visitResponse: StoreVisitResponse? = nil, couponResponse: StoreCouponSimpleResponse? = nil) {
        store = PlatformStore(response: storeResponse)
        coupon = couponResponse
        if let visitResponse {
            visitInfo = VisitInfo(response: visitResponse)
        } else {
            visitInfo = nil
        }
    }
}

public extension MyPageStore {
    struct VisitInfo {
        public let visitType: VisitType
        public let visitDate: String

        public init(response: StoreVisitResponse) {
            visitType = response.type
            visitDate = response.visitDate
        }
    }
}
