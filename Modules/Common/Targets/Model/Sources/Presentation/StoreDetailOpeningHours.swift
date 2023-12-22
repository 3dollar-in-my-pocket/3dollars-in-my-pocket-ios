import Foundation

public struct StoreDetailOpeningHours: Hashable {
    public let startTime: String
    public let endTime: String
    
    public init?(response: StoreOpeningHoursResponse?) {
        guard let response else { return nil }
        
        self.startTime = response.startTime
        self.endTime = response.endTime
    }
}
