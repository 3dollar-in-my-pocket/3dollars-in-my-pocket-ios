import Foundation

public struct SDButton: Decodable, Equatable, Hashable {
    public let text: SDText?
    public let image: SDImage?
    public let imageAlignment: SDButtonImageAlignment?
    public let link: SDLink?
    public let customAction: SDCustomAction?
    public let style: SDButtonStyle
}

public enum SDButtonImageAlignment: String, Decodable, Equatable, Hashable {
    case start = "START"
    case end = "END"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try SDButtonImageAlignment(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public struct SDButtonStyle: Decodable, Equatable, Hashable {
    public let backgroundColor: String
    public let border: SDBorder?

    public init(backgroundColor: String, border: SDBorder? = nil) {
        self.backgroundColor = backgroundColor
        self.border = border
    }
}
