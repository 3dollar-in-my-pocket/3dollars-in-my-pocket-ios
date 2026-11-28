import Foundation

import Model

protocol BottomNavigationStoring: AnyObject {
    var response: BottomNavigationResponse? { get set }
}

final class BottomNavigationStore: BottomNavigationStoring {
    static let shared = BottomNavigationStore()

    private let lock = NSLock()
    private var storedResponse: BottomNavigationResponse?

    var response: BottomNavigationResponse? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storedResponse
        }
        set {
            lock.lock()
            storedResponse = newValue
            lock.unlock()
        }
    }
}
