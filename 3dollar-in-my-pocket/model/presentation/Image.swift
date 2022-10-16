struct Image {
    let imageId: Int
    let url: String
    
    init(response: StoreImageResponse) {
        self.imageId = response.imageId
        self.url = response.url
    }
}
