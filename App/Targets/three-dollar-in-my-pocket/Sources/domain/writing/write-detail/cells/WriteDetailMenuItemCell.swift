import UIKit
import Combine

import DesignSystem

final class WriteDetailMenuItemCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 40 - 24, height: 44)
        static let space: CGFloat = 12
        static let nameWidth = (size.width - space) * 0.3
    }
    
    let nameField = TextField(placeholder: "ex) 슈크림")
    
    let priceField = TextField(placeholder: "ex) 3개 2천원")
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameField.text = nil
        priceField.text = nil
    }
    
    override func setup() {
        contentView.addSubViews([
            nameField,
            priceField
        ])
    }
    
    override func bindConstraints() {
        nameField.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(Layout.nameWidth)
        }
        
        priceField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalToSuperview()
            $0.left.equalTo(nameField.snp.right).offset(Layout.space)
        }
    }
    
    func bind(viewModel: WriteDetailMenuGroupViewModel?, index: Int) {
        guard let viewModel = viewModel else { return }
        
        nameField.text = viewModel.output.menus[safe: index]?.name
        priceField.text = viewModel.output.menus[safe: index]?.price
        
        nameField.publisher(for: \.text)
            .dropFirst()
            .map { $0 ?? "" }
            .map { (index, $0) }
            .subscribe(viewModel.input.inputMenuName)
            .store(in: &cancellables)
        
        priceField.publisher(for: \.text)
            .dropFirst()
            .map { $0 ?? "" }
            .map { (index, $0) }
            .subscribe(viewModel.input.inputMenuPrice)
            .store(in: &cancellables)
    }
}

extension WriteDetailMenuItemCell {
    final class TextField: UITextField {
        private var cancellables = Set<AnyCancellable>()
        
        init(placeholder: String? = nil) {
            super.init(frame: .zero)
            
            setup()
            bindEvent()
            if let placeholder = placeholder {
                setPlaceholder(text: placeholder)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            delegate = self
            layer.cornerRadius = 12
            layer.borderWidth = 0
            layer.borderColor = DesignSystemAsset.Colors.mainPink.color.cgColor
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
            leftViewMode = .always
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
            rightViewMode = .always
            font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
            backgroundColor = DesignSystemAsset.Colors.gray10.color
            returnKeyType = .done
        }
        
        private func setPlaceholder(text: String) {
            let attributedString = NSAttributedString(
                string: text,
                attributes: [
                    .font: DesignSystemFontFamily.Pretendard.regular.font(size: 14),
                    .foregroundColor: DesignSystemAsset.Colors.gray40.color
                ])
            attributedPlaceholder = attributedString
        }
        
        private func bindEvent() {
            controlPublisher(for: .editingDidBegin)
                .withUnretained(self)
                .sink { owner, _ in
                    owner.layer.borderWidth = 1
                }
                .store(in: &cancellables)
            
            controlPublisher(for: .editingDidEnd)
                .withUnretained(self)
                .sink { owner, _ in
                    owner.layer.borderWidth = 0
                }
                .store(in: &cancellables)
        }
    }
}

extension WriteDetailMenuItemCell.TextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
