import UIKit

public protocol MultipartRequestType: RequestType {
    var boundary: String { get }
    var data: Data { get }
}

public extension MultipartRequestType {
    var param: Encodable? {
        return nil
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var header: HTTPHeaderType {
        return .multipart(boundary: boundary)
    }
}
