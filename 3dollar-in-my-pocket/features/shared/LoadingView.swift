import UIKit
import Lottie

class LoadingView: BaseView {
    let lottie = AnimationView(name: "loading").then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
        $0.play()
    }
    
    override func setup() {
        backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.2)
        addSubViews(lottie)
    }
    
    override func bindConstraints() {
        lottie.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }
    }
}
