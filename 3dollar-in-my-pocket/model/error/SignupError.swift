import Foundation

enum SignupError: Int, LocalizedError {
  case alreadyExistedNickname = 409
  case badRequest = 400
  
  var errorDescription: String? {
    switch self {
    case .alreadyExistedNickname:
      return ""
    case .badRequest:
      return "잘못된 형식의 닉네임입니다."
    }
  }
}
