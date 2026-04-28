import Foundation

public struct SDChip: Decodable, Equatable, Hashable {
    public let image: SDImage?
    public let text: SDText
    public let style: SDChipStyle?

    public init(image: SDImage?, text: SDText, style: SDChipStyle?) {
        self.image = image
        self.text = text
        self.style = style
    }
}

public struct SDChipStyle: Decodable, Equatable, Hashable {
    public let backgroundColor: String

    public init(backgroundColor: String) {
        self.backgroundColor = backgroundColor
    }
}
