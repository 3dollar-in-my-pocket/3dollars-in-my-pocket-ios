import Foundation

public struct ReviewApiResponse: Decodable {
    public let createdAt: String
    public let updatedAt: String
    public let reviewId: Int
    public let rating: Int
    public let contents: String
    public let status: String
    public let isOwner: Bool
}
