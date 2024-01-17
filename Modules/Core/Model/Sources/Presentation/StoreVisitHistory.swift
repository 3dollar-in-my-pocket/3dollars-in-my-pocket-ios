import Foundation

public struct StoreVisitHistory: Hashable {
    public let type: VisitType
    public let visitTime: String
    public let name: String
    
    public init(response: StoreVisitWithUserApiResponse) {
        self.type = VisitType(value: response.visit.type)
        self.visitTime = response.visit.visitDate
        self.name = response.visitor.name
    }
    
    public init(type: VisitType, visitTime: String, name: String) {
        self.type = type
        self.visitTime = visitTime
        self.name = name
    }
}
