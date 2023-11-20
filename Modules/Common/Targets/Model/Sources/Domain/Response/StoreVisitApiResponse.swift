import Foundation

public struct StoreVisitApiResponse: Decodable {
    public let createdAt: String
    public let updatedAt: String
    public let visitId: String
    public let type: String
    public let visitDate: String
}

