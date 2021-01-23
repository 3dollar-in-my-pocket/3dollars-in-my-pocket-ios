import UIKit
import RxSwift

class StoreInfoCell: BaseTableViewCell {
  
  static let registerId = "\(StoreInfoCell.self)"
  
  let infoContainer = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
  }
  
  let storeTypeLabel = UILabel().then{
    $0.text = "store_detail_type".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let storeTypeValueLabel = UILabel().then {
    $0.textColor = UIColor(r: 255, g: 161, b: 170)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.text = "노점"
  }
  
  let storeDaysLabel = UILabel().then{
    $0.text = "store_detail_days".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let dayStackView = DayStackView(dayStackSize: .small)
  
  let paymentLabel = UILabel().then {
    $0.text = "store_detail_payment".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let cardLabel = UILabel().then {
    $0.textColor = UIColor(r: 161, g: 161, b: 161)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.text = "store_detail_payment_card".localized
  }
  
  let cardCircleView = UIView().then {
    $0.backgroundColor = UIColor(r: 161, g: 161, b: 161)
    $0.layer.cornerRadius = 4
  }
  
  let transferLabel = UILabel().then {
    $0.text = "store_detail_transfer".localized
    $0.textColor = UIColor(r: 161, g: 161, b: 161)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
  }
  
  let transferCircleView = UIView().then {
    $0.backgroundColor = UIColor(r: 161, g: 161, b: 161)
    $0.layer.cornerRadius = 4
  }
  
  let cashLabel = UILabel().then {
    $0.textColor = UIColor(r: 161, g: 161, b: 161)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.text = "store_detail_payment_cash".localized
  }
  
  let cashCircleView = UIView().then {
    $0.backgroundColor = UIColor(r: 161, g: 161, b: 161)
    $0.layer.cornerRadius = 4
  }
  
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    addSubViews(
      infoContainer, storeTypeLabel, storeTypeValueLabel, storeDaysLabel,
      dayStackView, paymentLabel, cardLabel, cardCircleView, transferLabel,
      transferCircleView, cashLabel, cashCircleView
    )
  }
  
  override func bindConstraints() {
    self.infoContainer.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(19)
      make.bottom.equalTo(self.paymentLabel).offset(22)
      make.bottom.equalToSuperview()
    }
    
    self.storeTypeLabel.snp.makeConstraints { make in
      make.left.equalTo(self.infoContainer).offset(16)
      make.top.equalTo(self.infoContainer).offset(19)
    }
    
    self.storeTypeValueLabel.snp.makeConstraints { make in
      make.right.equalTo(self.infoContainer).offset(-16)
      make.centerY.equalTo(self.storeTypeLabel)
    }
    
    self.storeDaysLabel.snp.makeConstraints { make in
      make.left.equalTo(self.storeTypeLabel)
      make.top.equalTo(self.storeTypeLabel.snp.bottom).offset(19)
    }
    
    self.dayStackView.snp.makeConstraints { make in
      make.centerY.equalTo(self.storeDaysLabel)
      make.right.equalTo(self.infoContainer).offset(-16)
    }
    
    self.paymentLabel.snp.makeConstraints { make in
      make.left.equalTo(self.storeTypeLabel)
      make.top.equalTo(self.storeDaysLabel.snp.bottom).offset(19)
    }
    
    self.cardLabel.snp.makeConstraints { make in
      make.right.equalTo(self.infoContainer).offset(-23)
      make.centerY.equalTo(self.paymentLabel)
    }
    
    self.cardCircleView.snp.makeConstraints { make in
      make.width.height.equalTo(8)
      make.centerY.equalTo(self.cardLabel)
      make.right.equalTo(self.cardLabel.snp.left).offset(-6)
    }
    
    self.transferLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.paymentLabel)
      make.right.equalTo(self.cardCircleView.snp.left).offset(-11)
    }
    
    self.transferCircleView.snp.makeConstraints { make in
      make.centerY.equalTo(self.paymentLabel)
      make.right.equalTo(self.transferLabel.snp.left).offset(-6)
      make.width.height.equalTo(8)
    }
    
    self.cashLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.paymentLabel)
      make.right.equalTo(self.transferCircleView.snp.left).offset(-11)
    }
    
    self.cashCircleView.snp.makeConstraints { make in
      make.centerY.equalTo(self.paymentLabel)
      make.right.equalTo(self.cashLabel.snp.left).offset(-6)
      make.width.height.equalTo(8)
    }
  }
}
