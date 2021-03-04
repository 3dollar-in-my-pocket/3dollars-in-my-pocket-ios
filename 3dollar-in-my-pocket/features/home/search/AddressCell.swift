import UIKit

class AddressCell: BaseTableViewCell {
  
  static let registerId = "\(AddressCell.self)"
  
  let buildingName = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 16)
  }
  
  let addressLabel = UILabel().then {
    $0.textColor = UIColor(r: 114, g: 114, b: 114)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
  }
  
  let dividorView = UIView().then {
    $0.backgroundColor = UIColor(r: 244, g: 244, b: 244)
  }
  
  
  override func setup() {
    self.selectionStyle = .none
    self.addSubViews(buildingName,addressLabel, dividorView)
  }
  
  override func bindConstraints() {
    self.buildingName.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(16)
    }
    
    self.addressLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.buildingName)
      make.top.equalTo(self.buildingName.snp.bottom).offset(6)
    }
    
    self.dividorView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.height.equalTo(1)
      make.top.equalTo(self.addressLabel.snp.bottom).offset(16)
      make.bottom.equalToSuperview()
    }
  }
  
  func bind(document: PlaceDocument) {
    self.buildingName.text = document.placeName
    if document.roadAddressName.isEmpty {
      self.addressLabel.text = document.addressName
    } else {
      self.addressLabel.text = document.roadAddressName
    }
  }
  
  func bind(document: AddressDocument) {
    if document.roadAddress.buildingName.isEmpty {
      if document.roadAddress.addressName.isEmpty {
        self.buildingName.text = document.address.addressName
      } else {
        self.buildingName.text = document.roadAddress.addressName
      }
    } else {
      self.buildingName.text = document.roadAddress.buildingName
      if document.roadAddress.addressName.isEmpty {
        self.addressLabel.text = document.address.addressName
      } else {
        self.addressLabel.text = document.roadAddress.addressName
      }
    }
  }
}
