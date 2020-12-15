import Alamofire

extension AFDataResponse {
  
  func isSuccess() -> Bool {
    if let statusCode = self.response?.statusCode,
       statusCode == 200 {
      return true
    } else {
      return false
    }
  }
}
