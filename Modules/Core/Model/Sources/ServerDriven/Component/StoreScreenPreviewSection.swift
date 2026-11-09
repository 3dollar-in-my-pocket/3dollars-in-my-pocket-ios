import Foundation

public struct StoreScreenPreviewSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let header: StorePreviewHeader
    public let metadata: StorePreviewMetadata
    public let actionBars: [SDActionBar]
    public let images: [SDImage]
    public let style: SDSurfaceStyle?
    public let additionalInfos: StoreScreenPreviewAdditionalInfos
    public let contributorActionBar: SDActionBar?
    public let impressionLog: SDImpressionLog?
    public let bodies: [StorePreviewBody]?
    public let markers: [HomeListCardMarker]?
}

public struct StoreScreenPreviewAdditionalInfos: Decodable, Equatable, Hashable {
    public let type: String
    public let isSubscriber: Bool?
    public let storeId: String?
    public let storeType: String?
}

extension StoreScreenPreviewSection {
    private enum CodingKeys: String, CodingKey {
        case type
        case sectionId
        case header
        case metadata
        case actionBars
        case images
        case style
        case additionalInfos
        case contributorActionBar
        case impressionLog
        case bodies
        case markers
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            type: try container.decode(StoreSectionType.self, forKey: .type),
            sectionId: try container.decodeIfPresent(String.self, forKey: .sectionId),
            header: try container.decode(StorePreviewHeader.self, forKey: .header),
            metadata: try container.decode(StorePreviewMetadata.self, forKey: .metadata),
            actionBars: try container.decode([SDActionBar].self, forKey: .actionBars),
            images: try container.decode([SDImage].self, forKey: .images),
            style: try container.decodeIfPresent(SDSurfaceStyle.self, forKey: .style),
            additionalInfos: try container.decodeIfPresent(StoreScreenPreviewAdditionalInfos.self, forKey: .additionalInfos)
                ?? StoreScreenPreviewAdditionalInfos(type: "STORE", isSubscriber: nil, storeId: nil, storeType: nil),
            contributorActionBar: try container.decodeIfPresent(SDActionBar.self, forKey: .contributorActionBar),
            impressionLog: try container.decodeIfPresent(SDImpressionLog.self, forKey: .impressionLog),
            bodies: try container.decodeIfPresent([StorePreviewBody].self, forKey: .bodies),
            markers: try container.decodeIfPresent([HomeListCardMarker].self, forKey: .markers)
        )
    }

    public var placeholder: StoreScreenPreviewSection {
        StoreScreenPreviewSection(
            type: type,
            sectionId: sectionId,
            header: header,
            metadata: metadata,
            actionBars: actionBars,
            images: images,
            style: style,
            additionalInfos: additionalInfos,
            contributorActionBar: nil,
            impressionLog: nil,
            bodies: bodies,
            markers: markers
        )
    }
}
