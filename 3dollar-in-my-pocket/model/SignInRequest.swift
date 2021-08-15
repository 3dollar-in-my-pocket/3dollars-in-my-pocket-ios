struct SigninRequest: Equatable {
  
  let socialType: SocialType
  let token: String
  
  var parameters: [String: Any] {
    return [
      "socialType": socialType.rawValue,
      "token": token
    ]
  }
}
