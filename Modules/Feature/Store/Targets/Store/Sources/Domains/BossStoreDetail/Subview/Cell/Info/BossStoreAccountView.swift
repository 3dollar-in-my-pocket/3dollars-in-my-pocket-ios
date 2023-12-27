import UIKit

import Common
import Model
import DesignSystem

final class BossStoreAccountView: BaseView {
    enum Layout {
        static let height: CGFloat = 70
    }
    
    private let containerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.gray100.color
        label.text = Strings.BossStoreDetail.Info.accountTitle
        return label
    }()
    
    private let accountNumberLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        return label
    }()
    
    let copyButton: Button.Normal = {
        let button = Button.Normal(size: .h34, text: Strings.BossStoreDetail.Info.copy)
        button.enabledBackgroundColor = Colors.gray80.color
        button.backgroundColor = Colors.gray80.color
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.contentEdgeInsets = .init(top: 8, left: 14, bottom: 8, right: 14)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        
        return button
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            titleLabel,
            accountNumberLabel,
            copyButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Layout.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.trailing.lessThanOrEqualTo(copyButton.snp.leading).offset(-12)
            $0.height.equalTo(18)
        }
        
        accountNumberLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.trailing.equalTo(titleLabel)
            $0.height.equalTo(18)
        }
        
        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(containerView)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView).priority(.high)
        }
    }
    
    func bind(account: StoreAccountNumber) {
        accountNumberLabel.text = "\(account.bank.description) \(account.accountNumber)"
    }
}
