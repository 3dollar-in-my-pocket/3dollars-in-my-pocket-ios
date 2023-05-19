public enum HTTPError: Int, Error {
  case badRequest = 400
  case unauthorized = 401
  case forbidden = 403
  case notFound = 404
  case internalServierError = 500
  case badGateway = 502
  case maintenance = 503
}

extension HTTPError {
  public var description: String {
    switch self {
    case .badRequest:
      return "http_error_bad_request".localized
    case .unauthorized:
      return "http_error_unauthorized".localized
    case .forbidden:
      return "http_error_forbidden".localized
    case .notFound:
      return "http_error_not_found".localized
    case .internalServierError:
      return "http_error_internal_server_error".localized
    case .badGateway:
      return "http_error_bad_gateway".localized
    case .maintenance:
      return "http_error_maintenance".localized
    }
  }
}
