import Foundation

public struct SDActionBar: Decodable, Equatable, Hashable {
    public let type: HomeFilterBarType
    public let button: SDButton
    public let clickLog: SDClickLog?
}
