import Model

public protocol MyPageRepository {
    func fetchMyStoreVisits(input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<StoreVisitWithStoreApiResponse>, Error>
    func fetchMyFavoriteStores(input: CursorRequestInput) async -> Result<StoreFavoriteFolderApiResponse, Error>
    /// 유저가 등록한 가게들을 조회합니다.
    func fetchMyStores(input: CursorRequestInput) async -> Result<ContentsWithCursorWithTotalCountResponse<UserStoreWithVisitsResponse>, Error>
}

public struct MyPageRepositoryImpl: MyPageRepository {
    public init() { }

    public func fetchMyStoreVisits(input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<StoreVisitWithStoreApiResponse>, Error> {
        let request = MyPageApi.fetchMyStoreVisits(input: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchMyFavoriteStores(input: CursorRequestInput) async -> Result<StoreFavoriteFolderApiResponse, Error> {
        let request = MyPageApi.fetchMyFavoriteStores(input: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchMyStores(input: CursorRequestInput) async -> Result<ContentsWithCursorWithTotalCountResponse<UserStoreWithVisitsResponse>, Error> {
        let request = MyPageApi.fetchMyStores(input: input)

        return await NetworkManager.shared.request(requestType: request)
    }
}
