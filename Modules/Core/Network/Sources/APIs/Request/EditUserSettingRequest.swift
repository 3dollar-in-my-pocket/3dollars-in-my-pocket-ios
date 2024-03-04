import Foundation

import Model

struct EditUserSettingRequest: RequestType {
    let input: UserAccountSettingPatchApiRequestInput
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .patch
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v4/my/user-settings"
    }
}
