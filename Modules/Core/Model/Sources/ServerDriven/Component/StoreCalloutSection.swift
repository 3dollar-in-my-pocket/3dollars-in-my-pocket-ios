import Foundation

public struct StoreCalloutSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let content: StoreCalloutContent
    public let style: SDSurfaceStyle?
}

public struct StoreCalloutContent: Decodable, Equatable, Hashable {
    public let image: SDImage?
    public let text: SDText?
    public let title: SDText?
    public let subTitle: SDText?
    public let footerLeftButton: SDButton?
    public let style: SDSurfaceStyle?
}
