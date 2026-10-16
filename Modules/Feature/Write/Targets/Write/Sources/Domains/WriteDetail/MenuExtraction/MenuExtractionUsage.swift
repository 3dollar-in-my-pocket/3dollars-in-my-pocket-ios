import Combine

final class MenuExtractionUsage {
    let isAvailable = CurrentValueSubject<Bool, Never>(true)

    var isUsed: Bool {
        isAvailable.value.isNot
    }

    func markUsed() {
        isAvailable.send(false)
    }
}

enum MenuExtractionFlow: String {
    case create
    case edit
    case afterCreate = "after_create"
}
