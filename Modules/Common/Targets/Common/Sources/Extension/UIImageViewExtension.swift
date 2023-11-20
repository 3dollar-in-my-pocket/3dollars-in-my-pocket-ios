import UIKit
import Kingfisher

public extension UIImageView {
    func setImage(urlString: String?) {
        guard let urlString = urlString else { return }
        if let url = URL(string: urlString) {
            self.kf.setImage(with: url)
        } else {
            print("⚠️ setImage(urlString: String): 올바른 URl 형태가 아닙니다.")
        }
    }
}
