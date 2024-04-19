public struct PlaceResponse: Decodable {
    public let placeId: String
    public let location: LocationResponse
    public let placeName: String
    public let addressName: String?
    public let roadAddressName: String?
}
