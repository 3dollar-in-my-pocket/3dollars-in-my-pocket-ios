import Foundation

public protocol StoreSectionComponent: Equatable, Hashable, Decodable {
    var type: StoreSectionType { get }
    var sectionId: String? { get }
    var style: SDSurfaceStyle? { get }
}
