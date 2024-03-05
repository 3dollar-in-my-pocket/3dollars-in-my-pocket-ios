import Foundation

enum ViewType {
    case myPage
    case setting
    
    var title: String {
        switch self {
        case .myPage:
            return "마이 페이지"
        case .setting:
            return "설정"
        }
    }
}
