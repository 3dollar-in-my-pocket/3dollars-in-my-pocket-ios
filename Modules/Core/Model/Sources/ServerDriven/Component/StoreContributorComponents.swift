import Foundation

public struct CalloutCard: Decodable, Hashable, SDUComponent {
    public let type: SDUComponentTypes
    public let cardId: String
    public let title: SDText
    public let description: SDText?
    public let style: SDSurfaceStyle
}

public struct IconTextCard: Decodable, Hashable, SDUComponent {
    public let type: SDUComponentTypes
    public let cardId: String
    public let title: SDText
    public let subTitles: [SDText]?
    public let subTitleChip: SDChip?
    public let image: SDImage
    public let metadata: SDText?
    public let style: SDSurfaceStyle
}
