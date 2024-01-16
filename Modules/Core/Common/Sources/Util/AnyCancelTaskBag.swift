import Foundation

import Combine

public final class AnyCancelTaskBag {
    private var tasks: [any AnyCancellableTask] = []
    
    public init() {}

    public func add(task: any AnyCancellableTask) {
        tasks.append(task)
    }

    public func cancel() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    deinit {
        cancel()
    }
}


extension Task {
    public func store(in bag: AnyCancelTaskBag) {
        bag.add(task: self)
    }
}
