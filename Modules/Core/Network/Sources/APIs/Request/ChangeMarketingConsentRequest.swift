import Foundation

import Model

struct ChangeMarketingConsentRequest: RequestType {
    let requestInput: ChangeMarketingConsentInput
    
    var param: Encodable? {
        return requestInput
    }
    
    var method: RequestMethod {
        return .put
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/user/me/marketing-consent"
    }
}
