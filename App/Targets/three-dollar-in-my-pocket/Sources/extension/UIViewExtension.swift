import UIKit

extension UIView {
    @available(*, deprecated, message: "사라질 예정입니다.")
    func addSubViews(_ views: UIView...) {
        for view in views {
            self.addSubview(view)
        }
    }
    
    func addSubViews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
    
    func gesture(_ type: UIGestureRecognizer.GestureType) -> UIGestureRecognizer.GesturePublisher {
        return .init(view: self, gestureType: type)
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
