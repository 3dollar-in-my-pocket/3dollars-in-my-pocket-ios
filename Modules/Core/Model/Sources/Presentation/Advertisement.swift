import Foundation

public struct Advertisement {
    public let advertisementId: Int
    public let title: String?
    public let subTitle: String?
    public let extraContent: String?
    public let imageUrl: String?
    public let imageWidth: Int
    public let imageHeight: Int
    public let linkUrl: String?
    public let bgColor: String?
    public let fontColor: String?
    
    public init(response: AdvertisementResponse) {
        self.advertisementId = response.advertisementId
        self.title = response.title
        self.subTitle = response.subTitle
        self.extraContent = response.extraContent
        self.imageUrl = response.imageUrl
        self.imageWidth = response.imageWidth
        self.imageHeight = response.imageHeight
        self.linkUrl = response.linkUrl
        self.bgColor = response.bgColor
        self.fontColor = response.fontColor
    }
}

extension Advertisement: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(advertisementId)
    }
}
