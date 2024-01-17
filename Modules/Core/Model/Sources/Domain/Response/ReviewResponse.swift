import Foundation

public struct ReviewResponse: Decodable {
    public let reviewId: Int
    public let storeId: Int
    public let userId: Int
    public let contents: String
    public let rating: Int
    public let status: String
    public let createdAt: String
    public let updatedAt: String
}
