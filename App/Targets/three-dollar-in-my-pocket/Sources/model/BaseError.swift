import Foundation

enum BaseError: LocalizedError {
    case custom(String)
    case unknown
    case timeout
    case failDecoding
    case nilValue
    
    
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        case .unknown:
            return Strings.errorUnknown
        case .timeout:
            return Strings.httpErrorTimeout
        case .failDecoding:
            return Strings.errorFailedToJson
        case .nilValue:
            return Strings.errorValueIsNil
        }
    }
}
