import Foundation

public struct ImageResponse: Decodable, Hashable {
    public let imageUrl: String
    public let width: Int?
    public let height: Int?
    
    public init(imageUrl: String, width: Int? = nil, height: Int? = nil) {
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
    }
}
