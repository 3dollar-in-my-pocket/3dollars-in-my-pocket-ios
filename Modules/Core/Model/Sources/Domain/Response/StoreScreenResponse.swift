import Foundation

public struct StoreScreenResponse: Decodable {
    public let sections: [any StoreDetailComponent]
    public let storeRef: StoreReference
    
    public enum CodingKeys: String, CodingKey {
        case sections
        case storeRef
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.storeRef = try container.decode(StoreReference.self, forKey: .storeRef)
        
        var sectionsArray = try container.nestedUnkeyedContainer(forKey: .sections)
        var sections: [any StoreDetailComponent] = []
        
        var tempContainer = sectionsArray
        
        while !sectionsArray.isAtEnd {
            let preview = try sectionsArray.decode(TemporaryTypePreview.self)
            let sectionDecoder = try tempContainer.superDecoder()
            
            let component: any StoreDetailComponent
            switch preview.type {
            case .storeAccountNumber:
                component = try StoreAccountNumberSectionResponse(from: sectionDecoder)
            case .storeActionBar:
                component = try StoreActionBarSectionResponse(from: sectionDecoder)
            case .storeAdmobCard:
                component = try StoreAdmobCardSectionResponse(from: sectionDecoder)
            case .storeCategorizedMenus:
                component = try StoreCategorizedMenusSectionResponse(from: sectionDecoder)
            case .storeImageMenus:
                component = try StoreImageMenusSectionResponse(from: sectionDecoder)
            case .storeImages:
                component = try StoreImagesSectionResponse(from: sectionDecoder)
            case .storeInfo:
                component = try StoreInfoSectionResponse(from: sectionDecoder)
            case .storeMap:
                component = try StoreMapSectionResponse(from: sectionDecoder)
            case .storeNews:
                component = try StoreNewsSectionResponse(from: sectionDecoder)
            case .storeOpeningDays:
                component = try StoreOpeningDaysSectionResponse(from: sectionDecoder)
            case .storeOverview:
                component = try StoreOverviewSectionResponse(from: sectionDecoder)
            case .storeReviews:
                component = try StoreReviewsSectionResponse(from: sectionDecoder)
            case .storeVisits:
                component = try StoreVisitsSectionResponse(from: sectionDecoder)
            case .unknown:
                continue
            }
            
            sections.append(component)
        }
        
        self.sections = sections
    }
}

public struct StoreReference: Decodable {
    public let storeId: String
    public let storeType: StoreType
}

private struct TemporaryTypePreview: Decodable {
    let type: StoreDetailComponentType
}
