import Foundation

public struct SDImage: Decodable, Equatable, Hashable {
    public let url: String
    public let style: SDImageStyle
}

public struct SDImageStyle: Decodable, Equatable, Hashable {
    public let width: Double
    public let height: Double
}
