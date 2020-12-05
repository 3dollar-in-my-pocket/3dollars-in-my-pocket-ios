import UIKit

class SettingView: BaseView {
  
  let topBackground = UIView().then {
    $0.backgroundColor = UIColor(r: 32, g: 32, b: 32)
  }
  
  let backButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_back_white"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.text = "setting_title".localized
    $0.textColor = .white
    $0.font = UIFont(name: "SpoqaHanSans-Bold", size: 16)
  }
  
  let nicknameLabel = UILabel().then {
    $0.text = "닉네임"
    $0.font = UIFont(name: "SpoqaHanSans-Bold", size: 24)
    $0.textColor = .white
  }
  
  let nicknameModifyLabelButton = UIButton().then {
    $0.setTitle("setting_nickname_modify".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 243, g: 162, b: 169), for: .normal)
    $0.titleLabel?.font = UIFont(name: "SpoqaHanSans-Regular", size: 14)
  }
  
  let nicknameModifyButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_pencil"), for: .normal)
  }
  
  let middleLineView = UIView().then {
    $0.backgroundColor = UIColor(r: 43, g: 43, b: 43)
  }
  
  let tableView = UITableView().then {
    $0.backgroundColor = UIColor(r: 28, g: 28, b: 28)
    $0.tableFooterView = UIView()
    $0.separatorStyle = .none
    $0.contentInset = UIEdgeInsets(top: 12.5, left: 0, bottom: 0, right: 0)
  }
  
  
  override func setup() {
    backgroundColor = UIColor(r: 28, g: 28, b: 28)
    addSubViews(
      topBackground, backButton, titleLabel, nicknameLabel,
      nicknameModifyLabelButton, nicknameModifyButton, middleLineView,
      tableView
    )
  }
  
  override func bindConstraints() {
    self.backButton.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.top.equalToSuperview().offset(48)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.backButton)
    }
    
    self.nicknameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.top.equalTo(self.backButton.snp.bottom).offset(35)
    }
    
    self.nicknameModifyLabelButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24 * RatioUtils.widthRatio)
      make.centerY.equalTo(self.nicknameLabel)
    }
    
    self.nicknameModifyButton.snp.makeConstraints { make in
      make.right.equalTo(self.nicknameModifyLabelButton.snp.left).offset(-5)
      make.centerY.equalTo(self.nicknameModifyLabelButton)
      make.width.height.equalTo(16)
    }
    
    self.middleLineView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.height.equalTo(1)
      make.top.equalTo(self.nicknameLabel.snp.bottom).offset(24)
    }
    
    self.topBackground.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
      make.bottom.equalTo(self.middleLineView)
    }
    
    self.tableView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(self.middleLineView.snp.bottom)
    }
  }
  
  func bind(user: User) {
    self.nicknameLabel.text = user.nickname
  }
}
