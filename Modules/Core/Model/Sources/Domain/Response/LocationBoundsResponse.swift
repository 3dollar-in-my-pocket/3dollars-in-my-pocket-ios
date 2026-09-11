import Foundation

public struct LocationBoundsResponse: Decodable, Hashable {
    public let southWest: LocationResponse
    public let northEast: LocationResponse

    public init(southWest: LocationResponse, northEast: LocationResponse) {
        self.southWest = southWest
        self.northEast = northEast
    }
}
