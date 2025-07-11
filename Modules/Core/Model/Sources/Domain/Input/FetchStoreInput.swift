import Foundation

public struct FetchStoreInput: Encodable {
    public enum IncludeType: String, Encodable {
        case onwer = "OWNER"
        case openStatus = "OPEN_STATUS"
        case metadata = "METADTA"
    }
    
    public let storeId: String
    public let includes: [IncludeType]
    
    public init(storeId: String, includes: [IncludeType]) {
        self.storeId = storeId
        self.includes = includes
    }
}
