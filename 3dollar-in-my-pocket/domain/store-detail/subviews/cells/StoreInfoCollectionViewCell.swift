import UIKit

import Base
import RxSwift
import RxCocoa

final class StoreInfoCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(StoreInfoCollectionViewCell.self)"
    static let height: CGFloat = 133
  
    private let infoContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
  
    private let storeTypeLabel = UILabel().then {
        $0.text = R.string.localization.store_detail_type()
        $0.textColor = R.color.black()
        $0.font = .bold(size: 14)
    }
  
    private let storeTypeValueLabel = UILabel().then {
        $0.textColor = R.color.pink()
        $0.font = .regular(size: 14)
    }
  
    private let storeTypeEmptyLabel = UILabel().then {
        $0.textColor = R.color.gray30()
        $0.font = .regular(size: 14)
        $0.text = R.string.localization.store_detail_info_empty()
        $0.isHidden = false
    }
  
    private let storeDaysLabel = UILabel().then {
        $0.text = R.string.localization.store_detail_days()
        $0.textColor = R.color.black()
        $0.font = .bold(size: 14)
    }
  
    private let dayStackView = DayStackView()
  
    private let storeDaysEmptyLabel = UILabel().then {
        $0.textColor = R.color.gray30()
        $0.font = .regular(size: 14)
        $0.text = R.string.localization.store_detail_info_empty()
        $0.isHidden = true
    }
  
    private let paymentLabel = UILabel().then {
        $0.text = R.string.localization.store_detail_payment()
        $0.textColor = R.color.black()
        $0.font = .bold(size: 14)
    }
  
    private let paymentMethodView = PaymentMethodView()
  
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
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
        self.infoContainer.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(7)
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
    }
    
    func bind(store: Store) {
        self.setStoreType(storeType: store.storeType)
        self.setStoreDays(weekDays: store.appearanceDays)
        self.paymentMethodView.bind(paymentMethods: store.paymentMethods)
    }
    
    private func setStoreType(storeType: StreetFoodStoreType?) {
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
