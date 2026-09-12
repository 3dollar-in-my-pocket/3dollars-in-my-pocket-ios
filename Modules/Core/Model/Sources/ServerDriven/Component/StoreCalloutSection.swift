import Foundation

public struct StoreCalloutSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let content: StoreCalloutContent
}

public struct StoreCalloutContent: Decodable, Equatable, Hashable {
    public let title: SDText
    public let subTitle: SDText?
    public let footerLeftButton: SDButton?
}
