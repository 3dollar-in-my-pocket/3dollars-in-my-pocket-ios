import Foundation

enum BaseError: LocalizedError {
    case custom(String)
    case unknown
    case timeout
    case failDecoding
    case nilValue
    case errorContainer(ResponseContainer<String>)
    
    
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        case .unknown:
            return "error_unknown".localized
        case .timeout:
            return "http_error_timeout".localized
        case .failDecoding:
            return "error_failed_to_json".localized
        case .nilValue:
            return "error_value_is_nil".localized
        case .errorContainer(let errorContainer):
            return errorContainer.message
        }
    }
}
