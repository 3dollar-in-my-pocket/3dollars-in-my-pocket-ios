import UIKit

import Lottie

final class LoadingView: BaseView {
    let lottieView = LottieAnimationView(name: "loading").then {
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
        self.backgroundColor = .clear
        self.addSubViews(lottieView)
    }
    
    override func bindConstraints() {
        self.lottieView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }
    }
}
