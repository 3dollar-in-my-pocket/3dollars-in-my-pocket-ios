import Foundation

public struct CalloutCard: Decodable, Hashable, SDUComponent {
    public let type: SDUComponentTypes
    public let cardId: String
    public let promptTitle: SDTextSpans
    public let highlightMessage: SDTextSpans
    public let description: SDTextSpans
    public let style: SDSurfaceStyle
}

public struct IconTextCardData: Decodable, Hashable, SDUComponent {
    public let type: SDUComponentTypes
    public let cardId: String
    public let title: SDText
    public let subTitle: SDChip?
    public let image: SDImage
    public let metadata: SDText?
    public let style: SDSurfaceStyle
}
