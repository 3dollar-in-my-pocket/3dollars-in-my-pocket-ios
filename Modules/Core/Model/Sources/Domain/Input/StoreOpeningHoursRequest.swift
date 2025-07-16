import Foundation

public struct UserStoreOpeningHoursRequest: Encodable {
    public let startTime: String?
    public let endTime: String?
    
    public init(startTime: String?, endTime: String?) {
        self.startTime = startTime
        self.endTime = endTime
    }
}
