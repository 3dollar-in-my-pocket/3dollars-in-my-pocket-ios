import Foundation

public struct SDHeader: Decodable, Equatable, Hashable {
    public let title: SDText
    public let subTitle: SDText?
    public let trailingAction: SDButton?
}
