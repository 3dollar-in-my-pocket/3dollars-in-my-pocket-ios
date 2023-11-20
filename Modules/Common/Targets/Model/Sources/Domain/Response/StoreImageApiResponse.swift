import Foundation

public struct StoreImageApiResponse: Decodable {
    public let createdAt: String
    public let updatedAt: String
    public let imageId: Int
    public let url: String
}
