import Foundation

public struct FetchPopularStoresInput: Encodable {
    public let size: Int
    public let cursor: String?
    public let criteria: String
    public let district: String

    public init(
        size: Int = 30,
        cursor: String? = nil,
        criteria: String,
        district: String
    ) {
        self.size = size
        self.cursor = cursor
        self.criteria = criteria
        self.district = district
    }
}

extension FetchPopularStoresInput {
    enum FetchPopularStoresInputType: String {
        case mostReviews = "MOST_REVIEWS"
        case mostVisits  = "MOST_VISITS"
    }
}
