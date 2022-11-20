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
            return R.string.localization.setting_menu_policy()
            
        case .privacy:
            return R.string.localization.privacy_title()
            
        case .marketing:
            return R.string.localization.setting_marketing()
        }
    }
}
