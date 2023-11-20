import UIKit

import Model

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
}
