import Foundation

public struct SDText: Decodable, Equatable, Hashable {
    public let text: String
    public let isHtml: Bool
    public let fontColor: String

    public init(text: String, isHtml: Bool, fontColor: String) {
        self.text = text
        self.isHtml = isHtml
        self.fontColor = fontColor
    }
}
