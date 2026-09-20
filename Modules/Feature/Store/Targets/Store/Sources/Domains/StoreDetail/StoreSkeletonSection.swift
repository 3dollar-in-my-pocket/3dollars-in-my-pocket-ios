import Model

struct StoreSkeletonSection: StoreSectionComponent {
    var type: StoreSectionType { .unknown }
    var sectionId: String? { nil }
    var style: SDSurfaceStyle? { nil }
}
