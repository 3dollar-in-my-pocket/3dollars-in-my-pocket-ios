import Foundation

public struct MyStoreReview: Hashable {
    public let user: User
    public let store: PlatformStore
    public let reviewId: Int
    public let contents: String?
    public let createdAt: String
    public let rating: Int
    
    public init(response: StoreReviewWithDetailApiResponse) {
        self.user = User(response: response.reviewWriter)
        self.store = PlatformStore(response: response.store)
        self.reviewId = response.review.reviewId
        self.contents = response.review.contents
        self.createdAt = response.review.createdAt
        self.rating = response.review.rating
    }
}
