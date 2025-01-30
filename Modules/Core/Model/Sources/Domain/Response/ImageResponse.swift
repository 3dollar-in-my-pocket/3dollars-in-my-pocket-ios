import Foundation

public struct ImageResponse: Decodable, Hashable {
    public let imageUrl: String
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}
