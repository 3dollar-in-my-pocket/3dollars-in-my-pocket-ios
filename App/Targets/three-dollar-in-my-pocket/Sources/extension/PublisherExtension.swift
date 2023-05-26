import Combine

extension Publisher {
    var mapVoid : Publishers.Map<Self, Void> {
        map { _ in () }
    }
    
    func withUnretained<T: AnyObject>(_ object: T) -> Publishers.CompactMap<Self, (T, Self.Output)> {
        compactMap { [weak object] output in
            guard let object = object else {
                return nil
            }
            return (object, output)
        }
    }
}

