import Foundation

enum EditNicknameError: LocalizedError {
    case alreadyExistedNickname
    case badRequest
    
    init?(statusCode: Int?) {
        switch statusCode {
        case 409:
            self = .alreadyExistedNickname
            
        case 400:
            self = .badRequest
            
        default:
            return nil
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .alreadyExistedNickname:
            return ""
            
        case .badRequest:
            return "잘못된 형식의 닉네임입니다."
        }
    }
}
