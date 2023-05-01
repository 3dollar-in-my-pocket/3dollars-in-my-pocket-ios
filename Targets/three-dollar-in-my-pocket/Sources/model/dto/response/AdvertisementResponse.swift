import Foundation

struct AdvertisementResponse: Decodable {
    let id: Int
    let bgColor: String
    let extraContent: String?
    let imageHeight: Int
    let imageWidth: Int
    let fontColor: String
    let imageUrl: String
    let linkUrl: String
    let subTitle: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id = "advertisementId"
        case bgColor
        case extraContent
        case imageHeight
        case imageWidth
        case fontColor
        case imageUrl
        case linkUrl
        case subTitle
        case title
    }
    
    init() {
        self.id = 0
        self.bgColor = ""
        self.extraContent = nil
        self.imageHeight = 0
        self.imageWidth = 0
        self.fontColor = ""
        self.imageUrl = ""
        self.linkUrl = ""
        self.subTitle = ""
        self.title = ""
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.bgColor = try values.decodeIfPresent(String.self, forKey: .bgColor) ?? ""
        self.extraContent = try values.decodeIfPresent(String.self, forKey: .extraContent)
        self.imageHeight = try values.decodeIfPresent(Int.self, forKey: .imageHeight) ?? 0
        self.imageWidth = try values.decodeIfPresent(Int.self, forKey: .imageWidth) ?? 0
        self.fontColor = try values.decodeIfPresent(String.self, forKey: .fontColor) ?? ""
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.linkUrl = try values.decodeIfPresent(String.self, forKey: .linkUrl) ?? ""
        self.subTitle = try values.decodeIfPresent(String.self, forKey: .subTitle) ?? ""
        self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    }
}
