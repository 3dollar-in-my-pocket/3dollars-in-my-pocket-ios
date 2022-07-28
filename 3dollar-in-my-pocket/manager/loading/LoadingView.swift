import UIKit

import Base
import Lottie

final class LoadingView: Base.BaseView {
    let lottieView = AnimationView(name: "loading").then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
    }
    
    func startLoading() {
        self.lottieView.play()
    }
    
    func stopLoading() {
        self.lottieView.stop()
    }
    
    override func setup() {
        self.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.8)
        self.addSubViews(lottieView)
    }
    
    override func bindConstraints() {
        self.lottieView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }
    }
}
