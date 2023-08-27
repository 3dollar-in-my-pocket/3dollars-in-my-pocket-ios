import Foundation

import Model

struct RefreshDeviceRequest: RequestType {
    let requestInput: DeviceRequestInput
    
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
        return "/api/v1/device/token"
    }
}
