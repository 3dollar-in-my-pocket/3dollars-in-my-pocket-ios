struct UpdateReviewRequest: Requestable {
  let contents: String
  let rating: Int
  
  var params: [String : Any] {
    return [
      "contents": self.contents,
      "rating": self.rating
    ]
  }
  
  init(review: Review) {
    self.contents = review.contents
    self.rating = review.rating
  }
}
