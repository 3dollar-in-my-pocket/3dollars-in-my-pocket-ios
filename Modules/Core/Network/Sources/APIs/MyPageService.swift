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

// TODO: 하경 Request 나중에 옮기기
struct FetchMyUserRequest: RequestType {
    var param: Encodable? {
        return ["includeActivities": true]
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v4/my/user"
    }
}

struct FetchMyStoreVisitsRequest: RequestType {
    let requestInput: CursorRequestInput
    
    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v4/my/store-visits"
    }
}

struct fetchMyFavoriteStoresRequest: RequestType {
    let requestInput: CursorRequestInput
    
    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .auth
    }

    var path: String {
        return "/api/v2/my/favorite-stores"
    }
}

struct fetchMyStoresRequest: RequestType {
    let requestInput: CursorRequestInput
    let latitude: Double
    let longitude: Double
    
    var param: Encodable? {
        return requestInput
    }

    var method: RequestMethod {
        return .get
    }

    var header: HTTPHeaderType {
        return .custom([
            "X-Device-Latitude": String(latitude),
            "X-Device-Longitude": String(longitude)
        ])
    }

    var path: String {
        return "/api/v4/my/stores"
    }
}
