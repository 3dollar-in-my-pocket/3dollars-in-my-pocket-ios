import UIKit
import RxCocoa
import RxSwift

class BaseView: UIView {
  
  let disposeBag = DisposeBag()
  
  private let loadingView = LoadingView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    bindConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
    bindConstraints()
  }
  
  func setup() { }
  
  func bindConstraints() { }
  
  func showLoading(isShow: Bool) {
    if isShow {
      addSubview(loadingView)
      loadingView.snp.makeConstraints { (make) in
        make.edges.equalTo(0)
      }
      isUserInteractionEnabled = false
      self.loadingView.startLoading()
    } else {
      self.loadingView.stopLoading()
      isUserInteractionEnabled = true
      loadingView.removeFromSuperview()
    }
  }
}
