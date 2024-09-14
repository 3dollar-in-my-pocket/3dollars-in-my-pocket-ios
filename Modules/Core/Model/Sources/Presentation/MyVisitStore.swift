import Foundation

public struct MyVisitStore: Hashable {
    public let type: VisitType
    public let visitDate: String
    public let createdAt: String
    public let store: PlatformStore
    
    public init(response: StoreVisitWithStoreApiResponse) {
        self.type = response.visit.type
        self.visitDate = response.visit.visitDate
        self.createdAt = response.visit.createdAt
        self.store = PlatformStore(response: response.store)
    }
}
