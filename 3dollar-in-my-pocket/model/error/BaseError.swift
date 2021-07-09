import Foundation

enum BaseError: LocalizedError {
  case custom(String)
  
  var errorDescription: String? {
    switch self {
    case .custom(let message):
      return message
    }
  }
}
