import Model

public protocol CommunityServiceProtocol {
    func fetchPopularStores(input: FetchPopularStoresInput) async -> Result<ContentsWithCursorResposne<PlatformStoreResponse>, Error>
}

public struct CommunityService: CommunityServiceProtocol {
    public init() { }

    public func fetchPopularStores(input: FetchPopularStoresInput) async -> Result<ContentsWithCursorResposne<PlatformStoreResponse>, Error> {
        let request = FetchPopularStoresRequest(requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }
}
