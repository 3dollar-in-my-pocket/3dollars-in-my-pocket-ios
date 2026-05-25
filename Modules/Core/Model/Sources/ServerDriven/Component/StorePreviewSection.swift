import Foundation

public struct StorePreviewSection: Decodable, Hashable, StoreCardComponent {
    public let type: SDComponentType
    public let header: StorePreviewHeader
    public let metadata: StorePreviewMetadata
    public let actionBars: [StorePreviewActionBar]
    public let images: [SDImage]
    public let bodies: [StorePreviewBody]
    public let style: SDSurfaceStyle?
}

public struct StorePreviewHeader: Decodable, Equatable, Hashable {
    public let title: SDText?
    public let badge: SDImage?
}

public struct StorePreviewMetadata: Decodable, Equatable, Hashable {
    public let primary: [SDChip]
    public let secondary: [SDChip]
    public let separator: SDImage
}

public struct StorePreviewActionBar: Decodable, Equatable, Hashable {
    public let button: SDButton
    public let clickLog: SDClickLog
}

public struct StorePreviewBody: Decodable, Equatable, Hashable {
    public let text: SDText
    public let style: SDSurfaceStyle
}
