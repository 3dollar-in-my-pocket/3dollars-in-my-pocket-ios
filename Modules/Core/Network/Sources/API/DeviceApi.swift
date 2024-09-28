import Foundation

import Model

enum DeviceApi {
    case registerDevice(input: DeviceRequestInput)
    case refreshDevice(input: DeviceRequestInput)
}

extension DeviceApi: RequestType {
    var param: Encodable? {
        switch self {
        case .registerDevice(let input):
            return input
        case .refreshDevice(let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .registerDevice:
            return .post
        case .refreshDevice:
            return .put
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .registerDevice:
            return .auth
        case .refreshDevice:
            return .auth
        }
    }
    
    var path: String {
        switch self {
        case .registerDevice:
            return "/api/v1/device"
        case .refreshDevice:
            return "/api/v1/device/token"
        }
    }
}
