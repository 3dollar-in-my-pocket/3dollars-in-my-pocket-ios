struct Popup {
    
    var id: Int
    var imageUrl: String
    var linkUrl: String
    
    init(response: PopupResponse) {
        self.id = 0
        self.imageUrl = response.imageUrl
        self.linkUrl = response.linkUrl
    }
    
    init() {
        self.id = 0
        self.imageUrl = ""
        self.linkUrl = ""
    }
}
