struct AddReviewRequest: Requestable {
  
  let contents: String
  let rating: Int
  let storeId: Int
  
  var params: [String : Any] {
    return [
      "contents": contents,
      "rating": rating,
      "storeId": storeId
    ]
  }
  
  init(review: Review) {
    self.contents = review.contents
    self.rating = review.rating
    self.storeId = review.store.storeId
  }
}
