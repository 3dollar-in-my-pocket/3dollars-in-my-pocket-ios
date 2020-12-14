public enum HTTPError: Int, Error {
  case unauthorized = 401
  case forbidden = 403
  case maintenance = 503
}

extension HTTPError {
  public var description: String {
    switch self {
    case .unauthorized:
      return "토큰이 유효하지 않습니다."
    case .forbidden:
      return "탈퇴한 사용자입니다."
    case .maintenance:
      return "서버 점검중입니다."
    }
  }
}
