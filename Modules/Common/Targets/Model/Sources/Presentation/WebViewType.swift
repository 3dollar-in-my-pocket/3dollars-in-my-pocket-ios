import UIKit

public enum WebViewType {
    case policy
    case privacy
    case marketing
}

public extension WebViewType {
    var title: String {
        switch self {
        case .policy:
            return "이용 약관"
            
        case .privacy:
            return "개인정보처리방침"
            
        case .marketing:
            return "가슴속 3천원 마케팅 수신 동의"
        }
    }
}
