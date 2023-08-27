import Combine

public extension Publisher {
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
    
    func asyncMap<T>(_ transform: @escaping (Output) async -> T) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
    
    func compactMapValue<T: Any>() -> Publishers.CompactMap<Self, T> where Output == Result<T, Error> {
        compactMap { output in
            switch output {
            case .success(let value):
                return value
                
            default:
                return nil
            }
        }
    }
    
    func compactMapError<T: Any>() -> Publishers.CompactMap<Self, Error> where Output == Result<T, Error> {
        compactMap { output in
            switch output {
            case .failure(let error):
                return error
                
            default:
                return nil
            }
        }
    }
}
