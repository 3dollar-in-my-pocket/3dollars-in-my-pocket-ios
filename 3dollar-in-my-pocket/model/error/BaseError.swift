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
            return R.string.localization.error_unknown()
        case .timeout:
            return R.string.localization.http_error_timeout()
        case .failDecoding:
            return R.string.localization.error_failed_to_json()
        case .nilValue:
            return R.string.localization.error_value_is_nil()
        case .errorContainer(let errorContainer):
            return errorContainer.message
        }
    }
}
