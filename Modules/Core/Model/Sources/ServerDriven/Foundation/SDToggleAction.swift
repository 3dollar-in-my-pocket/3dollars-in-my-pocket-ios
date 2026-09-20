import Foundation

public struct SDToggleAction: Decodable, Equatable, Hashable {
    public let selected: SDButton
    public let unselected: SDButton
    public let isSelected: Bool
}
