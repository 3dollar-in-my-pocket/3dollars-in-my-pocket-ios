import Model

public protocol MyPageServiceProtocol {
    func fetchMyUser() async -> Result<UserWithDetailApiResponse, Error>
    func fetchMyStoreVisits(size: Int, cursur: String?) async -> Result<ContentsWithCursorResposne<StoreVisitWithStoreApiResponse>, Error>
    func fetchMyFavoriteStores(size: Int, cursur: String?) async -> Result<StoreFavoriteFolderApiResponse, Error>
    /// 유저가 등록한 가게들을 조회합니다.
    func fetchMyStores(input: CursorRequestInput, latitude: Double, longitude: Double) async -> Result<ContentsWithCursorWithTotalCountResponse<UserStoreWithVisitsApiResponse>, Error>
}

public struct MyPageService: MyPageServiceProtocol {
    public init() { }

    public func fetchMyUser() async -> Result<UserWithDetailApiResponse, Error> {
        let request = FetchMyUserRequest()

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchMyStoreVisits(size: Int, cursur: String?) async -> Result<ContentsWithCursorResposne<StoreVisitWithStoreApiResponse>, Error> {
        let input = CursorRequestInput(size: size, cursor: cursur)
        let request = FetchMyStoreVisitsRequest(requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchMyFavoriteStores(size: Int, cursur: String?) async -> Result<StoreFavoriteFolderApiResponse, Error> {
        let input = CursorRequestInput(size: size, cursor: cursur)
        let request = fetchMyFavoriteStoresRequest(requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchMyStores(input: CursorRequestInput, latitude: Double, longitude: Double) async -> Result<ContentsWithCursorWithTotalCountResponse<UserStoreWithVisitsApiResponse>, Error> {
        let request = fetchMyStoresRequest(requestInput: input, latitude: latitude, longitude: longitude)

        return await NetworkManager.shared.request(requestType: request)
    }
}
