import Foundation

import Networking

protocol BottomNavigationLoading: AnyObject {
    func load()
    func waitUntilLoaded(timeout: TimeInterval) async
}

final class BottomNavigationLoader: BottomNavigationLoading {
    private let repository: ScreenRepository
    private let store: BottomNavigationStoring
    private let lock = NSLock()
    private var loadTask: Task<Void, Never>?

    init(
        repository: ScreenRepository = ScreenRepositoryImpl(),
        store: BottomNavigationStoring = BottomNavigationStore.shared
    ) {
        self.repository = repository
        self.store = store
    }

    func load() {
        let repository = repository
        let store = store
        let task = Task {
            if case .success(let response) = await repository.getBottomNavigation() {
                store.response = response
            }
        }

        lock.lock()
        loadTask = task
        lock.unlock()
    }

    func waitUntilLoaded(timeout: TimeInterval) async {
        lock.lock()
        let task = loadTask
        lock.unlock()
        guard let task else { return }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let resumer = SingleResumer(continuation: continuation)
            Task {
                await task.value
                resumer.resume()
            }
            Task {
                try? await Task.sleep(nanoseconds: UInt64(max(timeout, 0) * 1_000_000_000))
                resumer.resume()
            }
        }
    }
}

private final class SingleResumer: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Never>?

    init(continuation: CheckedContinuation<Void, Never>) {
        self.continuation = continuation
    }

    func resume() {
        lock.lock()
        let continuation = continuation
        self.continuation = nil
        lock.unlock()
        continuation?.resume()
    }
}
