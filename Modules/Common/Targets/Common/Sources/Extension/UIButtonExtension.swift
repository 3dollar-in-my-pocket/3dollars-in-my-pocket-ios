import UIKit
import Kingfisher

public extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(backgroundImage, for: state)
    }
    
    func setImage(urlString: String?, state: UIControl.State = .normal, completion: (() -> Void)? = nil) {
        guard let urlString = urlString else { return }
        if let url = URL(string: urlString) {
            self.kf.setImage(with: url, for: state, completionHandler:  { _ in
                completion?()
            })
        } else {
            print("⚠️ setImage(urlString: String): 올바른 URl 형태가 아닙니다.")
        }
    }
}
