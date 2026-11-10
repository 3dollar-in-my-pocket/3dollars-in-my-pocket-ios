import Foundation

public struct StorePreviewHeader: Decodable, Equatable, Hashable {
    public let title: SDText?
    public let badge: SDImage?
}

public struct StorePreviewMetadata: Decodable, Equatable, Hashable {
    public let primary: [SDChip]
    public let secondary: [SDChip]
    public let separator: SDImage
}

public struct StorePreviewBody: Decodable, Equatable, Hashable {
    public let text: SDText
    public let style: SDSurfaceStyle
}
