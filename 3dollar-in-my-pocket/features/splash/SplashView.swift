import UIKit
import Lottie

class SplashView: BaseView {
  
  let lottie = AnimationView(name: "splash").then {
    $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    $0.contentMode = .scaleAspectFit
  }
  
  
  override func setup() {
    backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
    addSubViews(lottie)
  }
  
  override func bindConstraints() {
    lottie.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
}
