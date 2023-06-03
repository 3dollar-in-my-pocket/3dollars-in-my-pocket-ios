import UIKit

import DesignSystem

final class WriteDetailMenuItemCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 40 - 24, height: 44)
        static let space: CGFloat = 12
        static let nameWidth = (size.width - space) * 0.3
    }
    
    let nameField = TextField(placeholder: "ex) 슈크림")
    
    let descriptionField = TextField(placeholder: "ex) 3개 2천원")
    
    override func setup() {
        contentView.addSubViews([
            nameField,
            descriptionField
        ])
    }
    
    override func bindConstraints() {
        nameField.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(Layout.nameWidth)
        }
        
        descriptionField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalToSuperview()
            $0.left.equalTo(nameField.snp.right).offset(Layout.space)
        }
    }
}

extension WriteDetailMenuItemCell {
    final class TextField: UITextField {
        init(placeholder: String? = nil) {
            super.init(frame: .zero)
            
            setup()
            
            if let placeholder = placeholder {
                let attributedString = NSAttributedString(
                    string: placeholder,
                    attributes: [
                        .font: DesignSystemFontFamily.Pretendard.regular.font(size: 14),
                        .foregroundColor: DesignSystemAsset.Colors.gray40.color
                    ])
                attributedPlaceholder = attributedString
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            layer.cornerRadius = 12
            layer.borderWidth = 1
            layer.borderColor = DesignSystemAsset.Colors.mainPink.color.cgColor
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
            leftViewMode = .always
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
            rightViewMode = .always
            font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
            backgroundColor = DesignSystemAsset.Colors.gray10.color
        }
    }
}
