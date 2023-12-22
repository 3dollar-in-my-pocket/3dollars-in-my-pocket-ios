import Foundation

public struct StoreOpeningHoursRequest: Encodable {
    public let startTime: String
    public let endTime: String
    
    public init?(startTime: String?, endTime: String?) {
        guard let startTime,
              let endTime else { return nil }
        
        self.startTime = startTime
        self.endTime = endTime
    }
}
