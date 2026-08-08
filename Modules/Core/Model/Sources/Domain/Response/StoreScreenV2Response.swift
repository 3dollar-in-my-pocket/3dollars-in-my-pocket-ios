import Foundation

public struct StoreScreenV2Response: Decodable {
    public let sections: [any StoreSectionComponent]
    public let viewLog: SDPageViewLog

    private enum CodingKeys: String, CodingKey {
        case sections
        case viewLog
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var sectionsArray = try container.nestedUnkeyedContainer(forKey: .sections)
        var tempContainer = sectionsArray
        var sections: [any StoreSectionComponent] = []

        while !sectionsArray.isAtEnd {
            let preview = try sectionsArray.decode(TemporaryTypePreview.self)
            let sectionDecoder = try tempContainer.superDecoder()

            let component: any StoreSectionComponent
            switch preview.type {
            case .callout:
                component = try StoreCalloutSection(from: sectionDecoder)
            case .preview:
                component = try StoreScreenPreviewSection(from: sectionDecoder)
            case .map:
                component = try StoreMapSection(from: sectionDecoder)
            case .relatedStores:
                component = try StoreRelatedStoresSectionV2(from: sectionDecoder)
            case .admob:
                component = try StoreAdmobSection(from: sectionDecoder)
            case .tab:
                component = try StoreTabSection(from: sectionDecoder)
            case .edit:
                component = try StoreEditSection(from: sectionDecoder)
            case .coupon:
                component = try StoreCouponSection(from: sectionDecoder)
            case .visit:
                component = try StoreVisitSection(from: sectionDecoder)
            case .post:
                component = try StorePostSection(from: sectionDecoder)
            case .image:
                component = try StoreImageSection(from: sectionDecoder)
            case .appearanceDay:
                component = try StoreAppearanceDaySection(from: sectionDecoder)
            case .infoV1:
                component = try StoreInfoV1Section(from: sectionDecoder)
            case .infoV2:
                component = try StoreInfoV2Section(from: sectionDecoder)
            case .cta:
                component = try StoreCTASection(from: sectionDecoder)
            case .review:
                component = try StoreReviewSection(from: sectionDecoder)
            case .unknown:
                continue
            }

            sections.append(component)
        }

        self.sections = sections
        self.viewLog = try container.decode(SDPageViewLog.self, forKey: .viewLog)
    }
}

private struct TemporaryTypePreview: Decodable {
    let type: StoreSectionType
}
