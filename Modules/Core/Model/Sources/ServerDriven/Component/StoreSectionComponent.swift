import Foundation

public protocol StoreSectionComponent: Equatable, Hashable, Decodable {
    var type: StoreSectionType { get }
}
