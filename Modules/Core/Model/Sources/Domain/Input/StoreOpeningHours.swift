import Foundation

public struct StoreOpeningHours: Codable {
    public let startTime: String?
    public let endTime: String?
    
    public init(startTime: String?, endTime: String?) {
        self.startTime = startTime
        self.endTime = endTime
    }
}

public extension StoreOpeningHours {
    var isValid: Bool {
        return startTime != nil || endTime != nil
    }
}
