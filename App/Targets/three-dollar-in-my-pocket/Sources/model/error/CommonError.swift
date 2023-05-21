struct CommonError: Error, CustomStringConvertible {
  
  let description: String
  
  init(desc: String) {
    self.description = desc
  }
  
  init(error: Error) {
    self.description = error.localizedDescription
  }
}
