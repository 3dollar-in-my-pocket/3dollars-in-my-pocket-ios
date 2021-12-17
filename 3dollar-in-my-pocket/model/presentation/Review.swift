struct Review {
    
    let category: StoreCategory
    var contents: String
    let createdAt: String
    let reviewId: Int
    var rating: Int
    let store: Store
    let user: User
    
    init(rating: Int, contents: String) {
        self.category = .BUNGEOPPANG
        self.contents = contents
        self.createdAt = ""
        self.reviewId = -1
        self.rating = rating
        self.store = Store()
        self.user = User()
    }
    
    init(response: ReviewDetailResponse) {
        self.category = response.store.categories[0]
        self.contents = response.contents
        self.createdAt = response.createdAt
        self.reviewId = response.reviewId
        self.rating = response.rating
        self.store = Store(response: response.store)
        self.user = User(response: response.user)
    }
    
    init(response: ReviewWithWriterResponse) {
        self.category = .BUNGEOPPANG
        self.contents = response.contents
        self.createdAt = response.createdAt
        self.reviewId = response.reviewId
        self.rating = response.rating
        self.store = Store()
        self.user = User(response: response.user)
    }
}
