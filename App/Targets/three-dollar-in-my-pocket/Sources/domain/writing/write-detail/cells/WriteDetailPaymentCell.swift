import UIKit
import Combine

import DesignSystem

final class WriteDetailPaymentCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    var tapPublisher: PassthroughSubject<PaymentType, Never> {
        return paymentStackView.tapPublisher
    }
    
    private let paymentStackView = WriteDetailPaymentStackView()
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        contentView.addSubview(paymentStackView)
    }
    
    override func bindConstraints() {
        paymentStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20).priority(.high)
            $0.right.equalToSuperview().offset(-20).priority(.high)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

extension WriteDetailPaymentCell {
    final class WriteDetailPaymentStackView: UIStackView {
        enum Layout {
            static let size = CGSize(width: 100, height: 36)
            static let space: CGFloat = 8
        }
        
        let tapPublisher = PassthroughSubject<PaymentType, Never>()
        
        let cashCheckButton = PaymentCheckButton(title: ThreeDollarInMyPocketStrings.storePaymentCash)
        
        let cardCheckButton = PaymentCheckButton(title: ThreeDollarInMyPocketStrings.storePaymentCard)
        
        let transferCheckButton = PaymentCheckButton(title: ThreeDollarInMyPocketStrings.storePaymentTransfer)
        
        var cancellables = Set<AnyCancellable>()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setup()
            bindConstraints()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            alignment = .leading
            axis = .horizontal
            backgroundColor = .clear
            spacing = Layout.space
            distribution = .fillEqually
            
            addArrangedSubview(cashCheckButton)
            addArrangedSubview(cardCheckButton)
            addArrangedSubview(transferCheckButton)
            
            cashCheckButton.controlPublisher(for: .touchUpInside)
                .withUnretained(self)
                .sink(receiveValue: { owner, _ in
                    owner.cashCheckButton.isSelected.toggle()
                    owner.tapPublisher.send(.cash)
                })
                .store(in: &cancellables)
            
            cardCheckButton.controlPublisher(for: .touchUpInside)
                .withUnretained(self)
                .sink(receiveValue: { owner, _ in
                    owner.cardCheckButton.isSelected.toggle()
                    owner.tapPublisher.send(.card)
                })
                .store(in: &cancellables)
            
            transferCheckButton.controlPublisher(for: .touchUpInside)
                .withUnretained(self)
                .sink(receiveValue: { owner, _ in
                    owner.transferCheckButton.isSelected.toggle()
                    owner.tapPublisher.send(.transfer)
                })
                .store(in: &cancellables)
        }
        
        private func bindConstraints() {
            cashCheckButton.snp.makeConstraints {
                $0.size.equalTo(Layout.size).priority(.high)
            }
            
            cardCheckButton.snp.makeConstraints {
                $0.size.equalTo(Layout.size).priority(.high)
            }
            
            transferCheckButton.snp.makeConstraints {
                $0.size.equalTo(Layout.size).priority(.high)
            }
        }
    }
    
    final class PaymentCheckButton: UIButton {
        override var isSelected: Bool {
            didSet {
                layer.borderColor = isSelected ? DesignSystemAsset.Colors.mainPink.color.cgColor : DesignSystemAsset.Colors.gray30.color.cgColor
                tintColor = isSelected ? DesignSystemAsset.Colors.mainPink.color : DesignSystemAsset.Colors.gray40.color
            }
        }
        
        init(title: String) {
            super.init(frame: .zero)
            
            setup(title: title)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup(title: String) {
            setTitle(title, for: .normal)
            titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
            setImage(
                DesignSystemAsset.Icons.check.image.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
            tintColor = DesignSystemAsset.Colors.gray40.color
            setTitleColor(DesignSystemAsset.Colors.gray40.color, for: .normal)
            setTitleColor(DesignSystemAsset.Colors.mainPink.color, for: .selected)
            
            if let titleLabel = titleLabel {
                imageView?.snp.makeConstraints {
                    $0.centerY.equalTo(titleLabel)
                    $0.right.equalTo(titleLabel.snp.left).offset(-4).priority(.high)
                    $0.width.height.equalTo(16)
                }
            }
            layer.cornerRadius = 8
            layer.borderWidth = 1
            layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        }
    }
}
