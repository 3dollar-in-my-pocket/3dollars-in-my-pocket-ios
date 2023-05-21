struct Review {
    let category: StreetFoodStoreCategory
    var contents: String
    let createdAt: String
    let reviewId: Int
    var rating: Int
    let store: Store
    let user: User
    
    init(
        category: StreetFoodStoreCategory = .BUNGEOPPANG,
        contents: String = "",
        createdAt: String = "",
        reviewId: Int = -1,
        rating: Int = 0,
        store: Store = Store(),
        user: User = User()
    ) {
        self.category = category
        self.contents = contents
        self.createdAt = createdAt
        self.reviewId = reviewId
        self.rating = rating
        self.store = store
        self.user = user
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
    
    init(response: ReviewInfoResponse) {
        self.category = .BUNGEOPPANG
        self.contents = response.contents
        self.createdAt = response.createdAt
        self.reviewId = response.reviewId
        self.rating = response.rating
        self.store = Store(id: response.storeId)
        self.user = User()
    }
}

extension Review: Equatable {
    static func == (lhs: Review, rhs: Review) -> Bool {
        return lhs.reviewId == rhs.reviewId
    }
    
    /// 새로 생성하는 리뷰인지 판별하는 플래그
    var isNewReview: Bool {
        return self.reviewId == -1
    }
}
