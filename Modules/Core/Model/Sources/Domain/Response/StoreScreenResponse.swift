import Foundation

public struct StoreScreenResponse: Decodable {
    public let sections: [any StoreCardComponent]
    
    public enum CodingKeys: String, CodingKey {
        case sections
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var cardSectionsArray = try container.nestedUnkeyedContainer(forKey: .sections)
        var sections: [any StoreCardComponent] = []
        
        var tempContainer = cardSectionsArray
        
        while !cardSectionsArray.isAtEnd {
            let preview = try cardSectionsArray.decode(TemporaryTypePreview.self)
            let sectionDecoder = try tempContainer.superDecoder()
            
            let component: any StoreCardComponent
            switch preview.type {
            case .relatedStores:
                component = try StoreRelatedStoresSectionResponse(from: sectionDecoder)
            case .imagePreviewCard:
                component = try StoreImagePreviewCard(from: sectionDecoder)
            case .unknown:
                continue
            default:
                continue
            }
            
            sections.append(component)
        }
        self.sections = sections
    }
}

private struct TemporaryTypePreview: Decodable {
    let type: SDComponentType
}
    
