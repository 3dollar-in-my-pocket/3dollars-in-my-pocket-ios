import UIKit
import Lottie

class SplashView: BaseView {
  
  let lottie = AnimationView(name: "splash").then {
    $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    $0.contentMode = .scaleAspectFit
  }
  
  
  override func setup() {
    self.backgroundColor = R.color.gray100()
    self.addSubViews([lottie])
  }
  
  override func bindConstraints() {
    self.lottie.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
