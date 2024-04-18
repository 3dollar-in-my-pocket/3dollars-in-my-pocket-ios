import Foundation

public struct PlaceDocument: Decodable, Hashable {
    public let addressName: String
    public let y: String
    public let x: String
    public let roadAddressName: String
    public let placeName: String
    
    public init(addressName: String, y: String, x: String, roadAddressName: String, placeName: String) {
        self.addressName = addressName
        self.y = y
        self.x = x
        self.roadAddressName = roadAddressName
        self.placeName = placeName
    }
}
