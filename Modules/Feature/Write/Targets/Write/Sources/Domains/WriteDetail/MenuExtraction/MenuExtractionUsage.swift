import Combine
import Foundation

final class MenuExtractionUsage {
    let isAvailable = CurrentValueSubject<Bool, Never>(true)
    private(set) var menuImage: Data?

    var isUsed: Bool {
        isAvailable.value.isNot
    }

    func markUsed() {
        isAvailable.send(false)
    }

    func registerMenuImage(_ image: Data) {
        menuImage = image
    }

    func consumeMenuImage() -> Data? {
        defer { menuImage = nil }
        return menuImage
    }
}

enum MenuExtractionFlow: String {
    case create
    case edit
    case afterCreate = "after_create"
}
