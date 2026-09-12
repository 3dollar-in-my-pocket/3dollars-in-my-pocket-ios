import Foundation

public struct SDRatingChip: Decodable, Equatable, Hashable {
    public let images: [SDImage]
    public let style: SDSurfaceStyle?
}
