public struct StoreReviewWithDetailApiResponse: Decodable {
    public let review: ReviewApiResponse
    public let store: StoreResponse
    public let reviewWriter: UserResponse
}
