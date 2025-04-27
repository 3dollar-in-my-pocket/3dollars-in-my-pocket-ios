import Foundation

public struct FetchFeedInput: Encodable {
    public let cursor: String?
    public let size: Int?
    public let mapLatitude: Double?
    public let mapLongitude: Double?
    
    public init(
        cursor: String? = nil,
        size: Int? = 20,
        mapLatitude: Double?,
        mapLongitude: Double?
    ) {
        self.cursor = cursor
        self.size = size
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
    }
}
