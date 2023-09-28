import UIKit
import Combine

public extension UITextView {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextView.textDidChangeNotification,
            object: self
        )
        .map { ($0.object as? UITextView)?.text ?? "" }
        .eraseToAnyPublisher()
    }
}
