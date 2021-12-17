import UIKit
import Lottie

class SplashView: BaseView {
  
  let lottie = AnimationView(name: "splash").then {
    $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    $0.contentMode = .scaleAspectFit
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor(r: 28, g: 28, b: 28)
    self.addSubViews([lottie])
  }
  
  override func bindConstraints() {
    self.lottie.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func startAnimation(oncompletion: @escaping (() -> Void)) {
    self.alpha = 1.0
    self.lottie.play { [weak self] _ in
      UIView.animate(
        withDuration: 0.5,
        animations: { [weak self] in
          self?.alpha = 0
        }) { _ in
        oncompletion()
      }
    }
  }
}
