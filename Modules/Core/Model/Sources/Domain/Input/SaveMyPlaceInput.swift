public struct SaveMyPlaceInput: Encodable {
    public let location: Location
    public let placeName: String
    public let addressName: String
    public let roadAddressName: String
    
    public init(location: SaveMyPlaceInput.Location, placeName: String, addressName: String, roadAddressName: String) {
        self.location = location
        self.placeName = placeName
        self.addressName = addressName
        self.roadAddressName = roadAddressName
    }
}

extension SaveMyPlaceInput {
    public struct Location: Encodable {
        public let latitude: String
        public let longitude: String
        
        public init(latitude: String, longitude: String) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}
