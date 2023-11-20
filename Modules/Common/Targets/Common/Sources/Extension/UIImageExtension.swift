import UIKit

public extension UIImage {
    func withImageInset(insets: UIEdgeInsets) -> UIImage {
        let resultImageSize = CGSize(width: size.width + insets.left + insets.right,
                                     height: size.height + insets.top + insets.bottom)
        UIGraphicsBeginImageContextWithOptions(resultImageSize, false, scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func resizeImage(scaledTo width: CGFloat) -> UIImage {
        let oldWidth: CGFloat = self.size.width
        let scaleFactor: CGFloat = width / oldWidth

        let newHeight: CGFloat = self.size.height * scaleFactor
        let newWidth: CGFloat = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
