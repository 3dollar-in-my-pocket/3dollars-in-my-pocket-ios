import UIKit
import Combine

public extension AnyPublisher<UITapGestureRecognizer, Never> {
    func throttleClick() -> Publishers.Debounce<Self, DispatchQueue> {
        return self.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    }
}

public extension AnyPublisher<Void, Never> {
    func throttleClick() -> Publishers.Debounce<Self, DispatchQueue> {
        return self.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    }
}
