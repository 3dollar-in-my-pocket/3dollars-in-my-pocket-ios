import Foundation

import Networking

struct Advertisement {
    let advertisementId: Int
    let title: String?
    let subTitle: String?
    let extraContent: String?
    let imageUrl: String?
    let imageWidth: Int
    let imageHeight: Int
    let linkUrl: String?
    let bgColor: String?
    let fontColor: String?
    
    init(response: AdvertisementResponse) {
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
