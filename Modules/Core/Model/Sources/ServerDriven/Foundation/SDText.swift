import Foundation

public struct SDText: Decodable, Equatable, Hashable {
    public let text: String
    public let isHtml: Bool
    public let fontColor: String
}
