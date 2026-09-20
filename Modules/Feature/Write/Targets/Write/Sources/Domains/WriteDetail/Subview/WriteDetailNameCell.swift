import UIKit

import Common
import DesignSystem

final class WriteDetailNameCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = Colors.gray10.color
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    let nameField: UITextField = {
        let nameField = UITextField()
        nameField.font = Fonts.regular.font(size: 14)
        nameField.textColor = Colors.gray100.color
        nameField.attributedPlaceholder = NSAttributedString(string: Strings.writeDetailNamePlaceholer, attributes: [.foregroundColor: Colors.gray50.color])
        nameField.returnKeyType = .done
        return nameField
    }()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        nameField.delegate = self
        contentView.addSubViews([
            containerView,
            nameField
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        nameField.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.right.equalTo(containerView).offset(-12)
            $0.centerY.equalTo(containerView)
        }
    }
    
    func bind(name: String) {
        nameField.text = name
    }
}

extension WriteDetailNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
