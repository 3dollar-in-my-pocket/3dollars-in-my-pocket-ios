import UIKit

import Common
import Model
import DesignSystem

final class StoreDetailAccountNumberCell: BaseCollectionViewCell {
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
        return label
    }()
    
    private let accountNumberStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    private let copyButton: Button.Normal = {
        let button = Button.Normal(size: .h34)
        button.enabledBackgroundColor = Colors.gray80.color
        button.backgroundColor = Colors.gray80.color
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.contentEdgeInsets = .init(top: 8, left: 14, bottom: 8, right: 14)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        
        return button
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            containerView,
            titleLabel,
            accountNumberStackView,
            copyButton
        ])
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.trailing.lessThanOrEqualTo(copyButton.snp.leading).offset(-12)
            $0.height.equalTo(18)
        }
        
        accountNumberStackView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.trailing.equalTo(titleLabel)
            $0.height.equalTo(18)
        }
        
        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(containerView)
        }
    }
    
    func bind(viewModel: StoreDetailAccountNumberCellViewModel) {
        let data = viewModel.output.data
        
        titleLabel.setSDText(data.title)
        setupAccountNumberStackView(bank: data.bank, accountNumber: data.accountNumber, accountHolder: data.accountHolder)
        
        if let button = data.button {
            copyButton.setSDButton(button)
            copyButton.tapPublisher
                .throttleClick()
                .subscribe(viewModel.input.didTapCopyAccountNumber)
                .store(in: &cancellables)
        }
    }
    
    private func setupAccountNumberStackView(bank: SDText, accountNumber: SDText?, accountHolder: SDText?) {
        let bankLabel = generateSubtitleLabel(text: bank)
        accountNumberStackView.addArrangedSubview(bankLabel)
        
        if let accountNumber {
            let accountNumberLabel = generateSubtitleLabel(text: accountNumber)
            accountNumberStackView.addArrangedSubview(accountNumberLabel)
        }
        
        if let accountHolder {
            let accountHolderLabel = generateSubtitleLabel(text: accountHolder)
            accountNumberStackView.addArrangedSubview(accountHolderLabel)
        }
    }
    
    private func generateSubtitleLabel(text: SDText) -> UILabel {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        label.setSDText(text)
        return label
    }
}
