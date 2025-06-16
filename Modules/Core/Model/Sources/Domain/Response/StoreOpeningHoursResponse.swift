import Foundation

public struct StoreOpeningHoursResponse: Decodable, Hashable {
    public let startTime: String?
    public let endTime: String?
}
