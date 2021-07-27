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
  
  let storeTypeEmptyLabel = UILabel().then {
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.text = "store_detail_info_empty".localized
    $0.isHidden = false
  }
  
  let storeDaysLabel = UILabel().then{
    $0.text = "store_detail_days".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let dayStackView = DayStackView()
  
  let storeDaysEmptyLabel = UILabel().then {
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.text = "store_detail_info_empty".localized
    $0.isHidden = true
  }
  
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
  
  let storePaymentEmptyLabel = UILabel().then {
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.text = "store_detail_info_empty".localized
    $0.isHidden = true
  }
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    addSubViews(
      infoContainer, storeTypeLabel, storeTypeValueLabel, storeTypeEmptyLabel,
      storeDaysLabel, dayStackView, storeDaysEmptyLabel, paymentLabel,
      cardLabel, cardCircleView, transferLabel, transferCircleView,
      cashLabel, cashCircleView, storePaymentEmptyLabel
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
    
    self.storeTypeEmptyLabel.snp.makeConstraints { make in
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
    
    self.storeDaysEmptyLabel.snp.makeConstraints { make in
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
    
    self.storePaymentEmptyLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.paymentLabel)
      make.right.equalTo(self.infoContainer).offset(-16)
    }
  }
  
  func bind(store: Store) {
    self.setStoreType(storeType: store.storeType)
    self.setStoreDays(weekDays: store.appearanceDays)
    self.setStorePayment(paymentMethods: store.paymentMethods)
  }
  
  private func setStoreType(storeType: StoreType?) {
    self.storeTypeEmptyLabel.isHidden = (storeType != nil)
    self.storeTypeValueLabel.isHidden = (storeType == nil)
    if let storeType = storeType {
      self.storeTypeValueLabel.text = storeType.getString()
    }
  }
  
  private func setStoreDays(weekDays: [WeekDay]) {
    self.storeDaysEmptyLabel.isHidden = !weekDays.isEmpty
    self.dayStackView.isHidden = weekDays.isEmpty
    self.dayStackView.selectDays(weekDays: weekDays)
  }
  
  private func setStorePayment(paymentMethods: [PaymentType]) {
    self.storePaymentEmptyLabel.isHidden = !paymentMethods.isEmpty
    self.cashCircleView.isHidden = paymentMethods.isEmpty
    self.cashLabel.isHidden = paymentMethods.isEmpty
    self.cardCircleView.isHidden = paymentMethods.isEmpty
    self.cardLabel.isHidden = paymentMethods.isEmpty
    self.transferCircleView.isHidden = paymentMethods.isEmpty
    self.transferLabel.isHidden = paymentMethods.isEmpty
    
    if !paymentMethods.isEmpty {
      self.cardCircleView.backgroundColor = paymentMethods.contains(.card) ? UIColor(r: 255, g: 161, b: 170): UIColor(r: 161, g: 161, b: 161)
      self.cardLabel.textColor = paymentMethods.contains(.card) ? UIColor(r: 255, g: 161, b: 170): UIColor(r: 161, g: 161, b: 161)
      self.cashCircleView.backgroundColor = paymentMethods.contains(.cash) ? UIColor(r: 255, g: 161, b: 170): UIColor(r: 161, g: 161, b: 161)
      self.cashLabel.textColor = paymentMethods.contains(.cash) ? UIColor(r: 255, g: 161, b: 170): UIColor(r: 161, g: 161, b: 161)
      self.transferCircleView.backgroundColor = paymentMethods.contains(.transfer) ? UIColor(r: 255, g: 161, b: 170): UIColor(r: 161, g: 161, b: 161)
      self.transferLabel.textColor = paymentMethods.contains(.transfer) ? UIColor(r: 255, g: 161, b: 170): UIColor(r: 161, g: 161, b: 161)
    }
  }
}
