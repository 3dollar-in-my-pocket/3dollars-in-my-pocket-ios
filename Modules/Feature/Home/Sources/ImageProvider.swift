import UIKit

class ImageProvider {
    static func image(name: String) -> UIImage {
        return UIImage(named: name, in: Bundle(for: self), with: nil) ?? UIImage()
    }
}
