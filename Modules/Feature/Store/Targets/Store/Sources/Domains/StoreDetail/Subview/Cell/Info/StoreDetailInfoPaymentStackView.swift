import UIKit

import Model

final class StoreDetailInfoPaymentStackView: UIStackView {
    private let cashItemView = StoreDetailIntoPaymentStackItemView(method: .cash)
    
    private let accountTransferItemView = StoreDetailIntoPaymentStackItemView(method: .accountTransfer)
    
    private let cardItemView = StoreDetailIntoPaymentStackItemView(method: .card)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ paymentMethods: [PaymentMethod]) {
        for paymentMethod in paymentMethods {
            switch paymentMethod {
            case .cash:
                cashItemView.setSelected(true)
                
            case .accountTransfer:
                accountTransferItemView.setSelected(true)
                
            case .card:
                cardItemView.setSelected(true)
                
            case .unknown:
                break
            }
        }
    }
    
    private func setup() {
        spacing = 4
        axis = .horizontal
        addArrangedSubview(cashItemView)
        addArrangedSubview(accountTransferItemView)
        addArrangedSubview(cardItemView)
    }
}
