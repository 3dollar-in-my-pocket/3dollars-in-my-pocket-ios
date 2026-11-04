import Foundation

public struct ImageUploadResponse: Decodable {
    public let imageUrl: String
    public let width: Int?
    public let height: Int?

    public init(imageUrl: String, width: Int?, height: Int?) {
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
    }
}
