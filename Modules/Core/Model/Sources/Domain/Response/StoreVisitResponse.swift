import Foundation

public struct StoreVisitResponse: Decodable {
    public let visitId: String
    public let createdAt: String
    public let updatedAt: String
    public let type: VisitType
    public let visitDate: String
    public let isOwner: Bool
}

