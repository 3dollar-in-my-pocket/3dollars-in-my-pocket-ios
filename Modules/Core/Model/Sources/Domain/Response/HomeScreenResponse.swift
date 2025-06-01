import Foundation

public struct HomeScreenResponse: Decodable {
    public let sections: [any HomeCardComponent]
    public let cursor: CursorString?
    
    public enum CodingKeys: String, CodingKey {
        case sections
        case cursor
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cursor = try container.decodeIfPresent(CursorString.self, forKey: .cursor)
        
        var cardSectionsArray = try container.nestedUnkeyedContainer(forKey: .sections)
        var sections: [any HomeCardComponent] = []
        
        var tempContainer = cardSectionsArray
        
        while !cardSectionsArray.isAtEnd {
            let preview = try cardSectionsArray.decode(TemporaryTypePreview.self)
            let sectionDecoder = try tempContainer.superDecoder()
            
            let component: any HomeCardComponent
            switch preview.type {
            case .homeAdCard:
                component = try HomeAdCardSectionResponse(from: sectionDecoder)
            case .homeAdmob:
                component = try HomeAdmobCardSectionResponse(from: sectionDecoder)
            case .homeCard:
                component = try HomeCardSectionResponse(from: sectionDecoder)
            case .unknown:
                continue
            }
            
            sections.append(component)
        }
        self.sections = sections
    }
}

private struct TemporaryTypePreview: Decodable {
    let type: HomeCardComponentType
}
    
