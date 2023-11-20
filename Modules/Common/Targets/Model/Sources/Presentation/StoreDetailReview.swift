import Foundation

public struct StoreDetailReview: Hashable {
    public let user: User
    public let reviewId: Int
    public var contents: String
    public let createdAt: String
    public var rating: Int
    public let reportedByMe: Bool
    public var isFiltered: Bool
    public var isOwner: Bool
    
    public init(response: ReviewWithUserApiResponse) {
        self.user = User(response: response.reviewWriter)
        self.reviewId = response.review.reviewId
        self.contents = response.review.contents
        self.createdAt = response.review.createdAt
        self.rating = response.review.rating
        self.reportedByMe = response.reviewReport.reportedByMe
        self.isFiltered = response.review.status == "FILTERED"
        self.isOwner = response.review.isOwner
    }
}
