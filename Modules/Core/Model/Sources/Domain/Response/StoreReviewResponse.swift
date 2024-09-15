import Foundation

public struct StoreReviewResponse: Decodable {
    public let reviewId: Int
    public let storeId: Int
    public let userId: Int
    public let contents: String?
    public let rating: Int
    public let status: ReviewStatus
    public let isOwner: Bool
    public let createdAt: String
    public let updatedAt: String
}

public enum ReviewStatus: String, Decodable {
    case posted = "POSTED"
    case filtered = "FILTERED"
    case deleted = "DELETED"
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try ReviewStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
