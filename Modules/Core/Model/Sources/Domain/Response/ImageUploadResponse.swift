import Foundation

public struct ImageUploadResponse: Decodable {
    public let imageUrl: String
    public let width: Int?
    public let height: Int?
}
