import Foundation

public struct AddressDocument: Decodable {
    let roadAddress: RoadAddress
    let address: Address
}

extension AddressDocument {
    struct RoadAddress: Decodable {
        let addressName: String
        let region1DepthName: String
        let region2DepthName: String
        let region3DepthName: String
        let roadName: String
        let undergroundYn: String
        let mainBuildingNo: String
        let subBuildingNo: String
        let buildingName: String
        let zoneNo: String
        let y: String
        let x: String
    }
    
    struct Address: Decodable {
        let addressName: String
        let region1DepthName: String
        let region2DepthName: String
        let region3DepthName: String
        let region3DepthHName: String
        let hCode: String
        let bCode: String
        let mountainYn: String
        let mainAddressNo: String
        let subAddressNo: String
        let x: String
        let y: String
    }
    
    var name: String {
        if !roadAddress.buildingName.isEmpty {
            return roadAddress.buildingName
        } else if !roadAddress.addressName.isEmpty {
            return roadAddress.addressName
        } else {
            return address.addressName
        }
    }
}
