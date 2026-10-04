import Combine

final class MenuExtractionUsage {
    let isAvailable = CurrentValueSubject<Bool, Never>(true)

    func markUsed() {
        isAvailable.send(false)
    }
}
