public struct StoreReviewWithDetailApiResponse: Decodable {
    public let review: ReviewApiResponse
    public let store: PlatformStoreResponse
    public let reviewWriter: UserApiResponse
}
