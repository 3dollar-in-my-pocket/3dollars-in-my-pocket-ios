import Foundation

struct RefreshDeviceRequest: RequestType {
    let requestInput: DeviceRequestInput
    
    var param: Encodable? {
        return requestInput
    }
    
    var method: RequestMethod {
        return .put
    }
    
    var header: HTTPHeaderType {
        return .json
    }
    
    var path: String {
        return "/api/v1/device/token"
    }
}
