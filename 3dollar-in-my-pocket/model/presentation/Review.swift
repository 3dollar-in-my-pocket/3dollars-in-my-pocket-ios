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
  
  init(response: ReviewDetailResponse) {
    self.category = response.store.categories[0]
    self.contents = response.contents
    self.createdAt = response.createdAt
    self.reviewId = response.reviewId
    self.rating = response.rating
    self.storeId = response.store.storeId
    self.storeName = response.store.storeName
    self.user = User(response: response.user)
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
