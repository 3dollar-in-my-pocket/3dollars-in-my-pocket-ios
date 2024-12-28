import Foundation

import Model
import Networking

enum CommonApi {
    case createNonceToken
}

extension CommonApi: RequestType {
    var param: (any Encodable)? {
        return NonceCreateRequestInput()
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var path: String {
        return "/api/v1/nonce"
    }
}
