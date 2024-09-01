public struct MyPageStore {
    public let store: PlatformStore
    public let visitInfo: VisitInfo?

    public init(storeResponse: StoreResponse, visitResponse: StoreVisitApiResponse? = nil) {
        store = PlatformStore(response: storeResponse)
        if let visitResponse {
            visitInfo = VisitInfo(response: visitResponse)
        } else {
            visitInfo = nil
        }
    }
}

public extension MyPageStore {
    struct VisitInfo {
        public let vistType: VisitType
        public let visitDate: String

        public init(response: StoreVisitApiResponse) {
            vistType = VisitType(value: response.type)
            visitDate = response.visitDate
        }
    }
}
