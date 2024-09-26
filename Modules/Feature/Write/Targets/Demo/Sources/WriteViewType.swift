import Foundation

enum WriteViewType {
    case write
    
    var title: String {
        switch self {
        case .write:
            return "가게 제보화면"
        }
    }
}
