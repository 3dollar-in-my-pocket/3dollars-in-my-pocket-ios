import Foundation

import Model

enum DeviceApi {
    case updateDevice(input: UserDeviceUpsertRequest)
}

extension DeviceApi: RequestType {
    var param: Encodable? {
        switch self {
        case .updateDevice(let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .updateDevice:
            return .put
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .updateDevice:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .updateDevice:
            return "/api/v2/device"
        }
    }
}
