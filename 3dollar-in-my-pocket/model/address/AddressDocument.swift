struct AddressDocument: Decodable, Document {
    let roadAddress: RoadAddress
    let address: Address
    var name: String {
        if !roadAddress.buildingName.isEmpty {
            return roadAddress.buildingName
        } else if !roadAddress.addressName.isEmpty {
            return roadAddress.addressName
        } else {
            return address.addressName
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case roadAddress = "road_address"
        case address = "address"
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        roadAddress = try values.decodeIfPresent(RoadAddress.self, forKey: .roadAddress) ?? RoadAddress()
        address = try values.decodeIfPresent(Address.self, forKey: .address) ?? Address()
    }
}
