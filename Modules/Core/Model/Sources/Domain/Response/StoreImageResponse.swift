import Foundation

public struct StoreImageResponse: Decodable {
    public let createdAt: String
    public let updatedAt: String
    public let imageId: Int
    public let url: String
    public let isOwner: Bool
}
