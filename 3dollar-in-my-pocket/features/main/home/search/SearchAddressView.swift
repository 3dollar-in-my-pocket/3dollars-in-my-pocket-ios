import UIKit

class SearchAddressView: BaseView {
  
  let navigationView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    $0.backgroundColor = .white
  }
  
  let closeButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_close"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.text = "search_address_title".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.textColor = UIColor(r: 28, g: 28, b: 28)
  }
  
  let inputBoxContainer = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 244, g: 244, b: 244).cgColor
  }
  
  let searchImage = UIImageView().then {
    $0.image = UIImage(named: "ic_search")
  }
  
  let addressField = UITextField().then {
    $0.placeholder = "search_address_placeholder".localized
    $0.textColor = UIColor(r: 51, g: 51, b: 51)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
  }
  
  let searchButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_current_location"), for: .normal)
  }
  
  let addressTableVIew = UITableView().then {
    $0.backgroundColor = .white
    $0.tableFooterView = UIView()
    $0.rowHeight = UITableView.automaticDimension
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 226, g: 226, b: 226).cgColor
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    self.addSubViews(
      navigationView, closeButton, titleLabel, inputBoxContainer,
      searchImage, addressField, searchButton, addressTableVIew
    )
  }
  
  override func bindConstraints() {
    self.navigationView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(59)
    }
    
    self.closeButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalTo(self.titleLabel)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.navigationView).offset(-20)
    }
    
    self.searchButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.navigationView.snp.bottom).offset(32)
    }
    
    self.inputBoxContainer.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalTo(self.searchButton.snp.left).offset(-8)
      make.height.centerY.equalTo(self.searchButton)
    }
    
    self.searchImage.snp.makeConstraints { make in
      make.centerY.equalTo(self.inputBoxContainer)
      make.left.equalTo(self.inputBoxContainer).offset(12)
      make.width.height.equalTo(24)
    }
    
    self.addressField.snp.makeConstraints { make in
      make.centerY.equalTo(self.inputBoxContainer)
      make.left.equalTo(self.searchImage.snp.right).offset(11)
      make.right.equalTo(self.navigationView).offset(-11)
    }
    
    self.addressTableVIew.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.inputBoxContainer.snp.bottom).offset(24)
      make.bottom.equalTo(safeAreaLayoutGuide)
    }
  }
}
