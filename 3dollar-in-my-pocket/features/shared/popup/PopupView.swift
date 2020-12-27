import UIKit

class PopupView: BaseView {
  
  let bannerButton = UIButton().then {
    $0.backgroundColor = .gray
    $0.imageView?.contentMode = .scaleAspectFill
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
    $0.contentMode = .scaleAspectFill
  }
  
  let cancelButton = UIButton().then {
    $0.setTitle("popup_close".localized, for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = UIColor.init(r: 44, g: 44, b: 44)
    $0.contentVerticalAlignment = .top
    $0.contentEdgeInsets = UIEdgeInsets.init(top: 24, left: 0, bottom: 0, right: 0)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
  }
  
  let disableTodayButton = UIButton().then {
    $0.setTitle("popup_disable_today".localized, for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = UIColor.init(r: 44, g: 44, b: 44)
    $0.contentVerticalAlignment = .top
    $0.contentEdgeInsets = UIEdgeInsets.init(top: 24, left: 0, bottom: 0, right: 0)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
  }
  
  let verticalView = UIView().then {
    $0.backgroundColor = UIColor.init(r: 149, g: 149, b: 149)
  }
  
  
  override func setup() {
    backgroundColor = UIColor.init(r: 255, g: 255, b: 255, a:0.8)
    addSubViews(bannerButton, cancelButton, disableTodayButton, verticalView)
  }
  
  override func bindConstraints() {
    
    disableTodayButton.snp.makeConstraints { (make) in
      make.left.bottom.equalToSuperview()
      make.right.equalTo(self.snp.centerX)
      make.height.equalTo(101)
    }
    
    cancelButton.snp.makeConstraints { (make) in
      make.right.bottom.equalToSuperview()
      make.left.equalTo(self.snp.centerX)
      make.height.equalTo(101)
    }
    
    verticalView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.height.equalTo(30)
      make.width.equalTo(1)
      make.top.equalTo(disableTodayButton).offset(20)
    }
    
    bannerButton.snp.makeConstraints { (make) in
      make.left.top.right.equalToSuperview()
      make.bottom.equalTo(disableTodayButton.snp.top)
    }
  }
  
  func bind(event: Event) {
    bannerButton.kf.setImage(with: URL.init(string: event.imageUrl), for: .normal)
  }
}
