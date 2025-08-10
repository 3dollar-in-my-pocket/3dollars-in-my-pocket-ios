import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit
import CombineCocoa

extension PaymentMethodSectionView {
    private class PaymentMethodButton: UIButton {
        private let titleString: String
        
        override var isSelected: Bool {
            didSet {
                updateSelectState(isSelected)
            }
        }
        
        init(title: String) {
            self.titleString = title
            super.init(frame: .zero)
            
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = AttributedString(titleString, attributes: AttributeContainer([
                .font: Fonts.semiBold.font(size: 14),
                .foregroundColor: Colors.gray40.color
            ]))
            config.image = Icons.check.image.resizeImage(scaledTo: 16).withTintColor(Colors.gray40.color)
            config.imagePadding = 2
            config.background.backgroundColor = .clear
            
            configuration = config
            layer.borderWidth = 1
            layer.cornerRadius = 8
            layer.masksToBounds = true
        }
        
        private func updateSelectState(_ isSelected: Bool) {
            let borderColor = isSelected ? Colors.mainPink.color.cgColor : Colors.gray30.color.cgColor
            let image = Icons.check.image
                .resizeImage(scaledTo: 16)
                .withTintColor(isSelected ? Colors.mainPink.color : Colors.gray40.color)
            let title = AttributedString(titleString, attributes: AttributeContainer([
                .font: Fonts.semiBold.font(size: 14),
                .foregroundColor: isSelected ? Colors.mainPink.color : Colors.gray40.color
            ]))
            
            configuration?.image = image
            configuration?.attributedTitle = title
            layer.borderColor = borderColor
        }
    }
}

final class PaymentMethodSectionView: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "결제방식"
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let requiredLabel: UILabel = {
        let label = UILabel()
        label.text = "*다중선택 가능"
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.mainPink.color
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let cashButton = PaymentMethodButton(title: "현금")
    private let cardButton = PaymentMethodButton(title: "카드")
    private let accountButton = PaymentMethodButton(title: "계좌이체")
    
    var selectedPaymentMethods = PassthroughSubject<PaymentMethod, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubViews([
            titleLabel,
            requiredLabel,
            buttonStackView
        ])
        
        buttonStackView.addArrangedSubViews([
            cashButton,
            cardButton,
            accountButton
        ])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        requiredLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(requiredLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(64)
        }
    }
    
    private func bind() {
        cashButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.cashButton.isSelected.toggle()
                self?.selectedPaymentMethods.send(.cash)
            }
            .store(in: &cancellables)
        
        cardButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.cardButton.isSelected.toggle()
                self?.selectedPaymentMethods.send(.card)
            }
            .store(in: &cancellables)
        
        accountButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.accountButton.isSelected.toggle()
                self?.selectedPaymentMethods.send(.accountTransfer)
            }
            .store(in: &cancellables)
    }
    
    func selectPaymentMethods(_ methods: [PaymentMethod]) {
        cashButton.isSelected = methods.contains(.cash)
        cardButton.isSelected = methods.contains(.card)
        accountButton.isSelected = methods.contains(.accountTransfer)
    }
}

