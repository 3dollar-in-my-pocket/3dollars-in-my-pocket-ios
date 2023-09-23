import Model

public protocol CommunityServiceProtocol {
    func fetchPopularStores(input: FetchPopularStoresInput) async -> Result<ContentsWithCursorResposne<PlatformStoreResponse>, Error>
    /// 동네 인기 가게가 활성화된 동네 목록 조회
    func fetchPopularStoreNeighborhoods() async -> Result<NeighborhoodsResponse, Error>
}

public struct CommunityService: CommunityServiceProtocol {
    public init() { }

    public func fetchPopularStores(input: FetchPopularStoresInput) async -> Result<ContentsWithCursorResposne<PlatformStoreResponse>, Error> {
        let request = FetchPopularStoresRequest(requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchPopularStoreNeighborhoods() async -> Result<NeighborhoodsResponse, Error> {
        let request = FetchPopularStoreNeighborhoods()

        return await NetworkManager.shared.request(requestType: request)
    }
}
