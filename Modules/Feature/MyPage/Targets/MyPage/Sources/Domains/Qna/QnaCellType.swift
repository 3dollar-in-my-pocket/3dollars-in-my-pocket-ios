import Foundation

enum QnaCellType {
    case faq
    case inquiry
    
    var title: String {
        switch self {
        case .faq:
            return Strings.Qna.faq
        case .inquiry:
            return Strings.Qna.inquiry
        }
    }
}
