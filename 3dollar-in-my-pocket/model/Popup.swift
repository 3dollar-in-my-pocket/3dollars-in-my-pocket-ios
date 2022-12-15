struct Advertisement: Equatable {
    let id: Int
    let bgColor: String
    let extraContent: String?
    let imageWidth: Int
    let imageHeight: Int
    let fontColor: String
    let imageUrl: String
    let linkUrl: String
    let subTitle: String
    let title: String
    
    init(response: AdvertisementResponse) {
        self.id = 0
        self.bgColor = response.bgColor
        self.extraContent = response.extraContent
        self.imageWidth = response.imageWidth
        self.imageHeight = response.imageHeight
        self.fontColor = response.fontColor
        self.imageUrl = response.imageUrl
        self.linkUrl = response.linkUrl
        self.subTitle = response.subTitle
        self.title = response.title
    }
    
    init() {
        self.id = 0
        self.bgColor = ""
        self.extraContent = nil
        self.imageWidth = 0
        self.imageHeight = 0
        self.fontColor = ""
        self.imageUrl = ""
        self.linkUrl = ""
        self.subTitle = ""
        self.title = ""
    }
}
