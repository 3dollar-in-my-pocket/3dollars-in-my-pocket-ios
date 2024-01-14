import Foundation

public struct NeighborhoodsResponse: Decodable {
    public let neighborhoods: [NeighborhoodProvinceResponse]
}

public struct NeighborhoodProvinceResponse: Decodable {
    public let province: String
    public let description: String
    public let districts: [NeighborhoodDistrictResponse]
}

public struct NeighborhoodDistrictResponse: Decodable {
    public let district: String
    public let description: String
}
