import Foundation

import Combine

public protocol AnyCancellableTask {
    func cancel()
}

extension Task: AnyCancellableTask {}
