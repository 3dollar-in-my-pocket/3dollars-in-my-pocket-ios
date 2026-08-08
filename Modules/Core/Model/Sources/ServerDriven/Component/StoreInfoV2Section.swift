import Foundation

public struct StoreInfoV2Section: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let imageGallery: ImageGallery?
    public let detailCard: DetailCard?
    public let accountCards: [AccountCopyCard]
    public let menuListCard: MenuListCard?
}

public struct ImageGallery: Decodable, Equatable, Hashable {
    public let images: [SDImage]
}

public struct DetailCard: Decodable, Equatable, Hashable {
    public let rows: [DetailRow]
    public let style: SDSurfaceStyle
}

public enum DetailRow: Decodable, Equatable, Hashable {
    case link(DetailLinkRow)
    case text(DetailTextRow)
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let type = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .type)
        switch type {
        case "LINK":
            self = .link(try DetailLinkRow(from: decoder))
        case "TEXT":
            self = .text(try DetailTextRow(from: decoder))
        default:
            self = .unknown
        }
    }
}

public struct DetailLinkRow: Decodable, Equatable, Hashable {
    public let label: SDText
    public let value: SDText
    public let link: SDLink
}

public struct DetailTextRow: Decodable, Equatable, Hashable {
    public let title: SDText
    public let body: SDText
}

public struct AccountCopyCard: Decodable, Equatable, Hashable {
    public let title: SDText
    public let account: SDChip
    public let copyButton: SDButton
    public let style: SDSurfaceStyle
}

public struct MenuListCard: Decodable, Equatable, Hashable {
    public let items: [ImageMenuItem]
    public let moreButton: SDButton?
    public let style: SDSurfaceStyle
}

public struct ImageMenuItem: Decodable, Equatable, Hashable {
    public let image: SDImage?
    public let primaryText: SDText
    public let secondaryText: SDText?
}
