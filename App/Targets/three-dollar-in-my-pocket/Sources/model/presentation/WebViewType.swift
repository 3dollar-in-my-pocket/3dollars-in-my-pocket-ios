import UIKit

enum WebViewType {
    case policy
    case privacy
    case marketing
}

extension WebViewType {
    var url: String {
        switch self {
        case .policy:
            return Bundle.policyURL
            
        case .privacy:
            return Bundle.privacyURL
            
        case .marketing:
            return Bundle.marketingURL
        }
    }
    
    var title: String {
        switch self {
        case .policy:
            return "setting_menu_policy".localized
            
        case .privacy:
            return "privacy_title".localized
            
        case .marketing:
            return "setting_marketing".localized
        }
    }
}
