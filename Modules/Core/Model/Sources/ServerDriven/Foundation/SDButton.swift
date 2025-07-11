import Foundation

public struct SDButton: Decodable, Equatable, Hashable {
    public let text: SDText
    public let image: SDImage?
    public let link: SDLink?
    public let style: SDButtonStyle
}

public struct SDButtonStyle: Decodable, Equatable, Hashable {
    public let backgroundColor: String
}
