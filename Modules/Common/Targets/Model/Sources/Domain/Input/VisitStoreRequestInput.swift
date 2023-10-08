import Foundation

public struct VisitStoreRequestInput: Encodable {
    let storeId: Int
    let type: String
    
    public init(storeId: Int, visitType: String) {
        self.storeId = storeId
        self.type = visitType
    }
}
