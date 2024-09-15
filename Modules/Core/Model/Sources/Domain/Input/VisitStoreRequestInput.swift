import Foundation

public struct VisitStoreRequestInput: Encodable {
    let storeId: Int
    let type: VisitType
    
    public init(storeId: Int, visitType: VisitType) {
        self.storeId = storeId
        self.type = visitType
    }
}
