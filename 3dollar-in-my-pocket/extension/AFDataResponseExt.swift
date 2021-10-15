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
  
  func decode<T: Decodable>(class: T.Type) -> T? {
    guard let value = self.value else {
      return nil
    }
    guard let responseContainer: ResponseContainer<T> = JsonUtils.toJson(object: value) else {
      return nil
    }
    
    return responseContainer.data
  }
}
