import UIKit

final class PaymentMethodView: BaseView {
    private let cardLabel = UILabel().then {
        $0.textColor = R.color.gray40()
        $0.font = .regular(size: 14)
        $0.text = R.string.localization.store_detail_payment_card()
    }
    
    private let cardCircleView = UIView().then {
        $0.backgroundColor = R.color.gray30()
        $0.layer.cornerRadius = 4
    }
    
    private let transferLabel = UILabel().then {
        $0.textColor = R.color.gray40()
        $0.font = .regular(size: 14)
        $0.text = R.string.localization.store_detail_payment_transfer()
    }
    
    private let transferCircleView = UIView().then {
        $0.backgroundColor = R.color.gray30()
        $0.layer.cornerRadius = 4
    }
    
    private let cashLabel = UILabel().then {
        $0.textColor = R.color.gray40()
        $0.font = .regular(size: 14)
        $0.text = R.string.localization.store_detail_payment_cash()
    }
    
    private let cashCircleView = UIView().then {
        $0.backgroundColor = R.color.gray30()
        $0.layer.cornerRadius = 4
    }
    
    private let storePaymentEmptyLabel = UILabel().then {
        $0.textColor = R.color.gray30()
        $0.font = .regular(size: 14)
        $0.text = R.string.localization.store_detail_info_empty()
        $0.isHidden = true
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.cardLabel,
            self.cardCircleView,
            self.transferLabel,
            self.transferCircleView,
            self.cashLabel,
            self.cashCircleView,
            self.storePaymentEmptyLabel
        ])
    }
    
    override func bindConstraints() {
        self.cardLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.cardCircleView.snp.makeConstraints { make in
            make.width.height.equalTo(8)
            make.centerY.equalTo(self.cardLabel)
            make.right.equalTo(self.cardLabel.snp.left).offset(-6)
        }
        
        self.transferLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.cardLabel)
            make.right.equalTo(self.cardCircleView.snp.left).offset(-11)
        }
        
        self.transferCircleView.snp.makeConstraints { make in
            make.centerY.equalTo(self.cardLabel)
            make.right.equalTo(self.transferLabel.snp.left).offset(-6)
            make.width.height.equalTo(8)
        }
        
        self.cashLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.cardLabel)
            make.right.equalTo(self.transferCircleView.snp.left).offset(-11)
        }
        
        self.cashCircleView.snp.makeConstraints { make in
            make.centerY.equalTo(self.cardLabel)
            make.right.equalTo(self.cashLabel.snp.left).offset(-6)
            make.width.height.equalTo(8)
        }
        
        self.storePaymentEmptyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.cardLabel)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func bind(paymentMethods: [PaymentType]) {
        self.storePaymentEmptyLabel.isHidden = !paymentMethods.isEmpty
        self.cashCircleView.isHidden = paymentMethods.isEmpty
        self.cashLabel.isHidden = paymentMethods.isEmpty
        self.cardCircleView.isHidden = paymentMethods.isEmpty
        self.cardLabel.isHidden = paymentMethods.isEmpty
        self.transferCircleView.isHidden = paymentMethods.isEmpty
        self.transferLabel.isHidden = paymentMethods.isEmpty
        
        if !paymentMethods.isEmpty {
            self.cardCircleView.backgroundColor = paymentMethods.contains(.card)
            ? R.color.pink()
            : R.color.gray30()
            self.cardLabel.textColor = paymentMethods.contains(.card)
            ? R.color.pink()
            : R.color.gray30()
            self.cashCircleView.backgroundColor = paymentMethods.contains(.cash)
            ? R.color.pink()
            : R.color.gray30()
            self.cashLabel.textColor = paymentMethods.contains(.cash)
            ? R.color.pink()
            : R.color.gray30()
            self.transferCircleView.backgroundColor = paymentMethods.contains(.transfer)
            ? R.color.pink()
            : R.color.gray30()
            self.transferLabel.textColor = paymentMethods.contains(.transfer)
            ? R.color.pink()
            : R.color.gray30()
        }
    }
}
