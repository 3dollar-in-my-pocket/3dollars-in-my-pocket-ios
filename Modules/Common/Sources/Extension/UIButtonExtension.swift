import UIKit
import Kingfisher

public extension UIButton {
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
