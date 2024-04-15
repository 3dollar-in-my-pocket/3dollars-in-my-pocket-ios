import Foundation

public protocol NeighborhoodProtocol {
    var description: String { get }
    var isSelected: Bool { get }
    var hasChild: Bool { get }
}

public struct CommunityNeighborhoods: Hashable, NeighborhoodProtocol {
    public let district: String
    public let description: String
    public let isSelected: Bool
    public var hasChild: Bool {
        return false
    }

    public init(district: String, description: String, isSelected: Bool) {
        self.district = district
        self.description = description
        self.isSelected = isSelected
    }
}

public struct CommunityNeighborhoodProvince: Hashable, NeighborhoodProtocol {
    public let province: String
    public let description: String
    public let districts: [CommunityNeighborhoods]
    public var isSelected: Bool
    public var hasChild: Bool {
        return !districts.isEmpty
    }
    
    public init(province: String, description: String, districts: [CommunityNeighborhoods], isSelected: Bool) {
        self.province = province
        self.description = description
        self.districts = districts
        self.isSelected = isSelected
    }
}

public extension CommunityNeighborhoods {
    static var defaultValue: CommunityNeighborhoods {
        return CommunityNeighborhoods(
            district: "SEOUL_GANGNAM",
            description: "강남구",
            isSelected: true
        )
    }
}
