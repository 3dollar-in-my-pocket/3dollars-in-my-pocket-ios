import Foundation

public struct CommunityNeighborhoods: Hashable {
    public let district: String
    public let description: String
    public let isSelected: Bool

    public init(district: String, description: String, isSelected: Bool) {
        self.district = district
        self.description = description
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
