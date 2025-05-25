import Foundation

public struct SDChip: Decodable, Equatable, Hashable {
    public let image: SDImage?
    public let text: SDText
    public let style: SDChipStyle?
}

public struct SDChipStyle: Decodable, Equatable, Hashable {
    public let backgroundColor: String
}
