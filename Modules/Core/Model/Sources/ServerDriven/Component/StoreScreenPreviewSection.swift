import Foundation

public struct StoreScreenPreviewSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: StorePreviewHeader
    public let metadata: StorePreviewMetadata
    public let actionBars: [SDActionBar]
    public let images: [SDImage]
    public let style: SDSurfaceStyle
    public let additionalInfos: StoreScreenPreviewAdditionalInfos
    public let contributorActionBar: SDActionBar?
}

public struct StoreScreenPreviewAdditionalInfos: Decodable, Equatable, Hashable {
    public let type: String
    public let isSubscriber: Bool?
    public let storeId: String?
    public let storeType: String?
}

extension StoreScreenPreviewSection {
    public init(preview: StorePreviewSection, storeId: Int) {
        self.init(
            type: .preview,
            header: preview.header,
            metadata: preview.metadata,
            actionBars: preview.actionBars.map {
                SDActionBar(type: .actionBar, button: $0.button, clickLog: $0.clickLog)
            },
            images: preview.images,
            style: preview.style ?? SDSurfaceStyle(backgroundColor: "#FFFFFF"),
            additionalInfos: StoreScreenPreviewAdditionalInfos(
                type: preview.additionalInfos?.type ?? "STORE",
                isSubscriber: preview.additionalInfos?.isSubscriber,
                storeId: String(storeId),
                storeType: preview.additionalInfos?.storeType
            ),
            contributorActionBar: nil
        )
    }
}
