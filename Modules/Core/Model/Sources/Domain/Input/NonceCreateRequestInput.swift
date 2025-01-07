import Foundation

public struct NonceCreateRequestInput: Encodable {
    public let retention: String
    
    public init(retention: String = "PT1H") {
        self.retention = retention
    }
}
