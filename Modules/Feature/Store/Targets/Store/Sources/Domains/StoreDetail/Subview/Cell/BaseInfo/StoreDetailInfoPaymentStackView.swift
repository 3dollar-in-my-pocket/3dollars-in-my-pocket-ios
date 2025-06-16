import UIKit

import Model

final class StoreDetailBaseInfoPaymentStackView: UIStackView {
    private let cashItemView = StoreDetailBaseInfoPaymentStackItemView(method: .cash)
    
    private let accountTransferItemView = StoreDetailBaseInfoPaymentStackItemView(method: .accountTransfer)
    
    private let cardItemView = StoreDetailBaseInfoPaymentStackItemView(method: .card)
    
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
    
    func prepareForReuse() {
        cashItemView.setSelected(false)
        accountTransferItemView.setSelected(false)
        cardItemView.setSelected(false)
    }
    
    private func setup() {
        spacing = 4
        axis = .horizontal
        addArrangedSubview(cashItemView)
        addArrangedSubview(accountTransferItemView)
        addArrangedSubview(cardItemView)
    }
}
