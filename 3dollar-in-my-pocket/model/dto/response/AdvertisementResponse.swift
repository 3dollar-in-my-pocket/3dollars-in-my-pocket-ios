import Foundation

struct AdvertisementResponse: Decodable {
    let bgColor: String
    let fontColor: String
    let imageUrl: String
    let linkUrl: String
    let subTitle: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case bgColor
        case fontColor
        case imageUrl
        case linkUrl
        case subTitle
        case title
    }
    
    init() {
        self.bgColor = ""
        self.fontColor = ""
        self.imageUrl = ""
        self.linkUrl = ""
        self.subTitle = ""
        self.title = ""
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.bgColor = try values.decodeIfPresent(String.self, forKey: .bgColor) ?? ""
        self.fontColor = try values.decodeIfPresent(String.self, forKey: .fontColor) ?? ""
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.linkUrl = try values.decodeIfPresent(String.self, forKey: .linkUrl) ?? ""
        self.subTitle = try values.decodeIfPresent(String.self, forKey: .subTitle) ?? ""
        self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    }
}
