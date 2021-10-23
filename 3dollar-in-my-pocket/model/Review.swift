struct Review {
  
  let category: StoreCategory
  var contents: String
  let createdAt: String
  let reviewId: Int
  var rating: Int
  let storeId: Int
  let storeName: String
  let user: User
  
  init(rating: Int, contents: String) {
    self.category = .BUNGEOPPANG
    self.contents = contents
    self.createdAt = ""
    self.reviewId = -1
    self.rating = rating
    self.storeId = -1
    self.storeName = ""
    self.user = User()
  }
  
  init(reviewDetailResponse: ReviewDetailResponse) {
    self.category = reviewDetailResponse.categories[0]
    self.contents = reviewDetailResponse.contents
    self.createdAt = reviewDetailResponse.createdAt
    self.reviewId = reviewDetailResponse.reviewId
    self.rating = reviewDetailResponse.rating
    self.storeId = reviewDetailResponse.storeId
    self.storeName = reviewDetailResponse.storeName
    self.user = User(response: reviewDetailResponse.user)
  }
  
  init(response: ReviewWithWriterResponse) {
    self.category = .BUNGEOPPANG
    self.contents = response.contents
    self.createdAt = response.createdAt
    self.reviewId = response.reviewId
    self.rating = response.rating
    self.storeId = 0
    self.storeName = ""
    self.user = User(response: response.user)
  }
}
