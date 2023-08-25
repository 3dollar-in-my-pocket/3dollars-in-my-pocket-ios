import Foundation

struct RegisterDeviceRequest: RequestType {
    let requestInput: DeviceRequestInput
    
    var param: Encodable? {
        return requestInput
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v1/device"
    }
}
