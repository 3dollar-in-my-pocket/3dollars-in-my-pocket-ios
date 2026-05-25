import Foundation

public protocol StoreViewSessionCounterProtocol {
    func increment(storeId: Int) -> Int
    func count(storeId: Int) -> Int
}

public final class StoreViewSessionCounter: StoreViewSessionCounterProtocol {
    public static let shared = StoreViewSessionCounter()

    private let queue = DispatchQueue(label: "com.3dollars.StoreViewSessionCounter", attributes: .concurrent)
    private var counts: [Int: Int] = [:]

    private init() {}

    @discardableResult
    public func increment(storeId: Int) -> Int {
        var newValue = 0
        queue.sync(flags: .barrier) {
            let current = counts[storeId] ?? 0
            newValue = current + 1
            counts[storeId] = newValue
        }
        return newValue
    }

    public func count(storeId: Int) -> Int {
        queue.sync {
            counts[storeId] ?? 0
        }
    }
}
