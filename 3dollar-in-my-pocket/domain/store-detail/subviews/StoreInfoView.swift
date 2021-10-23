import UIKit
import RxSwift

class StoreInfoView: BaseView {
  
  let titleLabel = UILabel().then {
    $0.text = R.string.localization.store_detail_header_info()
    $0.textColor = .black
    $0.font = .semiBold(size: 18)
  }
  
  let updatedAtLabel = UILabel().then {
    $0.textColor = R.color.gray30()
    $0.font = .semiBold(size: 12)
  }
  
  let editButton = UIButton().then {
    $0.setTitle(R.string.localization.store_detail_header_modify_info(), for: .normal)
    $0.setTitleColor(R.color.red(), for: .normal)
    $0.titleLabel?.font = .bold(size: 12)
    $0.layer.cornerRadius = 15
    $0.backgroundColor = R.color.red()?.withAlphaComponent(0.2)
    $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
  }
  
  let infoContainer = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
  }
  
  let storeTypeLabel = UILabel().then {
    $0.text = R.string.localization.store_detail_type()
    $0.textColor = R.color.black()
    $0.font = .bold(size: 14)
  }
  
  let storeTypeValueLabel = UILabel().then {
    $0.textColor = R.color.pink()
    $0.font = .regular(size: 14)
  }
  
  let storeTypeEmptyLabel = UILabel().then {
    $0.textColor = R.color.gray30()
    $0.font = .regular(size: 14)
    $0.text = R.string.localization.store_detail_info_empty()
    $0.isHidden = false
  }
  
  let storeDaysLabel = UILabel().then {
    $0.text = R.string.localization.store_detail_days()
    $0.textColor = R.color.black()
    $0.font = .bold(size: 14)
  }
  
  let dayStackView = DayStackView()
  
  let storeDaysEmptyLabel = UILabel().then {
    $0.textColor = R.color.gray30()
    $0.font = .regular(size: 14)
    $0.text = R.string.localization.store_detail_info_empty()
    $0.isHidden = true
  }
  
  let paymentLabel = UILabel().then {
    $0.text = R.string.localization.store_detail_payment()
    $0.textColor = R.color.black()
    $0.font = .bold(size: 14)
  }
  
  let paymentMethodView = PaymentMethodView()
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews([
      self.titleLabel,
      self.updatedAtLabel,
      self.editButton,
      self.infoContainer,
      self.storeTypeLabel,
      self.storeTypeValueLabel,
      self.storeTypeEmptyLabel,
      self.storeDaysLabel,
      self.dayStackView,
      self.storeDaysEmptyLabel,
      self.paymentLabel,
      self.paymentMethodView
    ])
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(40)
    }
    
    self.updatedAtLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.titleLabel)
      make.left.equalTo(self.titleLabel.snp.right).offset(8)
    }
    
    self.editButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(32)
    }
    
    self.infoContainer.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(19)
      make.bottom.equalTo(self.paymentLabel).offset(22)
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
    
    self.paymentMethodView.snp.makeConstraints { make in
      make.right.equalTo(self.infoContainer)
      make.top.equalTo(self.paymentLabel)
      make.bottom.equalTo(self.paymentLabel)
    }
    
    self.snp.makeConstraints { make in
      make.bottom.equalTo(self.infoContainer)
    }
  }
  
  func bind(store: Store) {
    self.updatedAtLabel.text = DateUtils.toUpdatedAtFormat(dateString: store.updatedAt)
    self.setStoreType(storeType: store.storeType)
    self.setStoreDays(weekDays: store.appearanceDays)
    self.paymentMethodView.bind(paymentMethods: store.paymentMethods)
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
}
