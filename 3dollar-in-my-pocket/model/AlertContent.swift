struct AlertContent: Equatable {
  var title: String?
  var message: String?
  
  
  init(title: String? = nil, message: String? = nil) {
    self.title = title
    self.message = message
  }
  
  init(httpError: HTTPError) {
    self.init(title: nil, message: httpError.description)
  }
}
