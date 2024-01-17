import UIKit
import Combine

public extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .map { ($0.object as? UITextField)?.text ?? "" }
        .eraseToAnyPublisher()
    }
}
