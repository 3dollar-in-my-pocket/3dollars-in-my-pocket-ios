import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailBaseInfoPaymentStackItemView: BaseView {
    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = Colors.gray40.color
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    init(method: PaymentMethod) {
        super.init(frame: .zero)
        
        let title: String
        switch method {
        case .cash:
            title = Strings.StoreDetail.Info.PaymentMethod.cash
            
        case .accountTransfer:
            title = Strings.StoreDetail.Info.PaymentMethod.accountTransfer
            
        case .card:
            title = Strings.StoreDetail.Info.PaymentMethod.card
            
        case .unknown:
            title = ""
        }
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubViews([
            dotView,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        dotView.snp.makeConstraints {
            $0.size.equalTo(4)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.left.equalTo(dotView.snp.right).offset(4)
            $0.right.equalToSuperview().offset(-4)
            $0.height.equalTo(18)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(titleLabel).priority(.high)
            $0.bottom.equalTo(titleLabel).priority(.high)
            $0.right.equalTo(titleLabel).offset(4).priority(.high)
            $0.left.equalTo(dotView).offset(-4).priority(.high)
        }
    }
    
    func setSelected(_ isSelected: Bool) {
        dotView.backgroundColor = isSelected ? Colors.gray70.color : Colors.gray40.color
        titleLabel.textColor = isSelected ? Colors.gray70.color : Colors.gray40.color
    }
}
