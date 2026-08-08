import Foundation

public struct StoreCTASection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let content: StoreCTAContent
}

public struct StoreCTAContent: Decodable, Equatable, Hashable {
    public let title: SDText
    public let subTitle: SDText?
    public let footerLeftButton: SDButton?
}
