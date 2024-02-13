public struct StoreReviewWithDetailApiResponse: Decodable {
    public let review: ReviewApiResponse
    public let store: StoreApiResponse
    public let reviewWriter: UserApiResponse
}
