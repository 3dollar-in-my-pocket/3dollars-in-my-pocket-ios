import Foundation

import Model

enum StoreSectionFragment {
    static func candidates(for fragment: String) -> [StoreSectionType] {
        switch fragment.lowercased() {
        case "home", "preview":
            return [.preview]
        case "info", "info_v1", "info_v2":
            return [.infoV1, .infoV2]
        case "image", "images":
            return [.image]
        case "review", "reviews":
            return [.review]
        default:
            guard let type = StoreSectionType(rawValue: fragment.uppercased()), type != .unknown else { return [] }
            return [type]
        }
    }

    static func sectionIndex(for fragment: String, in sections: [any StoreSectionComponent]) -> Int? {
        if let index = sections.firstIndex(where: {
            $0.sectionId?.caseInsensitiveCompare(fragment) == .orderedSame
        }) {
            return index
        }
        for candidate in candidates(for: fragment) {
            if let index = sections.firstIndex(where: { $0.type == candidate }) {
                return index
            }
        }
        return nil
    }

    static func sectionType(for fragment: String, in sections: [any StoreSectionComponent]) -> StoreSectionType? {
        sectionIndex(for: fragment, in: sections).map { sections[$0].type }
    }
}
