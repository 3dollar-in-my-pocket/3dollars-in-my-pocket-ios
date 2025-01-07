import Foundation

public struct StoreVisitHistory: Hashable {
    public let type: VisitType
    public let name: String
    public let createdAt: String
    
    public init(response: StoreVisitWithUserResponse) {
        self.type = response.visit.type
        self.name = response.visitor.name
        self.createdAt = response.visit.createdAt
    }
    
    public init(
        type: VisitType,
        name: String,
        createdAt: String
    ) {
        self.type = type
        self.name = name
        self.createdAt = createdAt
    }
}
