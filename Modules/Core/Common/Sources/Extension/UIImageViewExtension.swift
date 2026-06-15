import UIKit
import Kingfisher
import Model
import SnapKit

public extension UIImageView {
    func setImage(urlString: String?) {
        guard let urlString = urlString else { return }
        if let url = URL(string: urlString) {
            self.kf.setImage(with: url)
        } else {
            print("⚠️ setImage(urlString: String): 올바른 URl 형태가 아닙니다.")
        }
    }
    
    func clear() {
        image = nil
        kf.cancelDownloadTask()
    }
    
    func setSDImage(_ sdImage: SDImage) {
        setImage(urlString: sdImage.url)
        
        snp.removeConstraints()
        snp.makeConstraints { make in
            make.width.equalTo(sdImage.style.width)
            make.height.equalTo(sdImage.style.height)
        }
    }
}
