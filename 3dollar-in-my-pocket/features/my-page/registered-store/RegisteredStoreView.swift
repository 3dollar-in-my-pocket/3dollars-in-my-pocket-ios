import UIKit

class RegisteredStoreView: BaseView {
  
  let backButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_back_white"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.text = "registered_store_title".localized
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
  }
  
  let tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.tableFooterView = UIView()
    $0.backgroundColor = .clear
    $0.showsVerticalScrollIndicator = false
    $0.rowHeight = UITableView.automaticDimension
    $0.contentInsetAdjustmentBehavior = .never
    
    let indicator = UIActivityIndicatorView(style: .large)
    
    indicator.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: 60
    )
    $0.tableFooterView = indicator
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
    self.addSubViews(backButton, titleLabel, tableView)
  }
  
  override func bindConstraints() {
    self.backButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(safeAreaLayoutGuide).offset(13)
      make.width.height.equalTo(24)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.backButton)
      make.centerX.equalToSuperview()
    }
    
    self.tableView.snp.makeConstraints { (make) in
      make.bottom.equalTo(safeAreaLayoutGuide)
      make.right.equalToSuperview()
      make.left.equalToSuperview()
      make.top.equalTo(self.backButton.snp.bottom).offset(10)
    }
  }
}
