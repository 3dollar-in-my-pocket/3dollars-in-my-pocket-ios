import Foundation

public struct SDImage: Decodable, Equatable, Hashable {
    public let url: String
    public let style: SDImageStyle

    public init(url: String, style: SDImageStyle) {
        self.url = url
        self.style = style
    }
}

public struct SDImageStyle: Decodable, Equatable, Hashable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}
