import Foundation

public struct NaverMapResponse: Decodable {
    public let results: [ReverseGeoLocation]
}

public extension NaverMapResponse {
    struct ReverseGeoLocation: Decodable {
        let name: String
        let region: Region
        let land: Land?
    }
    
    struct Region: Decodable {
        let area0: Area
        let area1: Area
        let area2: Area
        let area3: Area
        let area4: Area
    }

    struct Area: Decodable {
        let name: String
    }
    
    struct Land: Decodable {
        let number1: String
        let number2: String
        let name: String?
        let addition0: Addition?
    }

    struct Addition: Codable {
        let value: String
    }
    
    var address: String {
        if !results.isEmpty {
            var address = ""
            
            if results.count == 4 {
                address = "\(results[0].region.area1.name) \(results[0].region.area2.name)"
                if let name = results[3].land?.name {
                    address = "\(address) \(name)"
                }
                
                if let roadNumber1 = results[3].land?.number1 {
                    address = "\(address) \(roadNumber1)"
                    
                    if let roadNumber2 = results[3].land?.number2 {
                        if !roadNumber2.isEmpty {
                            address = "\(address)-\(roadNumber2)"
                        }
                    }
                }
            } else {
                address = "\(results[0].region.area1.name) \(results[0].region.area2.name) \(results[0].region.area3.name)"
                
                if results.count > 2 {
                    if let jibun1 = results[2].land?.number1 {
                        address = "\(address) \(jibun1)"
                        
                        if let jibun2 = results[2].land?.number2,
                           !jibun2.isEmpty {
                            address = "\(address)-\(jibun2)"
                        }
                    }
                }
            }
            
            return address
        } else {
            return "주소를 알 수 없는 위치입니다."
        }
    }
}
