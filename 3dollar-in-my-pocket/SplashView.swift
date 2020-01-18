import UIKit
import Lottie

class SplashView: BaseView {
    let lottie = LOTAnimationView(name: "data_1").then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.contentMode = .scaleAspectFit
        $0.loopAnimation = true
        $0.play()
    }
    
    override func setup() {
        backgroundColor = .white
        addSubViews(lottie)
    }
    
    override func bindConstraints() {
        lottie.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
    }
}
