import UIKit
import Lottie

class LoadingView: UIView {
  let lottie = AnimationView(name: "loading").then {
    $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    $0.contentMode = .scaleAspectFit
    $0.loopMode = .loop
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.bindConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startLoading() {
    self.lottie.play()
  }
  
  func stopLoading() {
    self.lottie.stop()
  }
  
  private func setup() {
    backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.8)
    addSubViews(lottie)
  }
  
  private func bindConstraints() {
    lottie.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.height.equalTo(150)
    }
  }
}
