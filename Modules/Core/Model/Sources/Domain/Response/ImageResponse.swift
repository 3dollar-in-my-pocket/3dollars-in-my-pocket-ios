import Foundation

public struct ImageResponse: Decodable {
    public let imageUrl: String
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}
