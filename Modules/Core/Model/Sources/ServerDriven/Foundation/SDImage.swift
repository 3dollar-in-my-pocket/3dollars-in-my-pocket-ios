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
    public let dimmed: Bool

    public init(width: Double, height: Double, dimmed: Bool = false) {
        self.width = width
        self.height = height
        self.dimmed = dimmed
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try container.decode(Double.self, forKey: .width)
        self.height = try container.decode(Double.self, forKey: .height)
        self.dimmed = try container.decodeIfPresent(Bool.self, forKey: .dimmed) ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case width
        case height
        case dimmed
    }
}
