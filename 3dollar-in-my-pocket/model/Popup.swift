struct Advertisement {
    let id: Int
    let bgColor: String
    let fontColor: String
    let imageUrl: String
    let linkUrl: String
    let subTitle: String
    let title: String
    
    init(response: AdvertisementResponse) {
        self.id = 0
        self.bgColor = response.bgColor
        self.fontColor = response.fontColor
        self.imageUrl = response.imageUrl
        self.linkUrl = response.linkUrl
        self.subTitle = response.subTitle
        self.title = response.title
    }
    
    init() {
        self.id = 0
        self.bgColor = ""
        self.fontColor = ""
        self.imageUrl = ""
        self.linkUrl = ""
        self.subTitle = ""
        self.title = ""
    }
}
