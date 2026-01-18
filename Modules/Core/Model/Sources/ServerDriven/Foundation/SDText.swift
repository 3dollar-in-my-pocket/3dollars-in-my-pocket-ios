import Foundation

public struct SDText: Decodable, Equatable, Hashable {
    public let text: String
    public let style: SDTextStyle
}

public struct SDTextStyle: Decodable, Equatable, Hashable {
    public let fontColor: String
    public let fontSize: Int?
    public let fontWeight: String?
}
