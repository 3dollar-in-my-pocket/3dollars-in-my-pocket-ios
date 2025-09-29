import UIKit
import Combine

import Common

final class NameTextField: BaseView {
    enum State {
        case focused
        case done
        case error
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.text = Strings.WriteDetailInfo.NameTextField.title
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.font = Fonts.regular.font(size: 14)
        field.textColor = Colors.gray90.color
        field.attributedPlaceholder = NSAttributedString(string: Strings.WriteDetailInfo.NameTextField.placeholder, attributes: [.foregroundColor: Colors.gray50.color])
        field.returnKeyType = .done
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    var textPublisher: AnyPublisher<String, Never> {
        textField.textPublisher
    }
    
    override func setup() {
        addSubViews([
            titleLabel,
            containerView,
            textField
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(7)
            $0.height.equalTo(44)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(12)
            $0.top.equalTo(containerView).offset(12)
            $0.trailing.equalTo(containerView).offset(-12)
            $0.bottom.equalTo(containerView).offset(-12)
        }
    }
    
    func setState(_ state: State) {
        switch state {
        case .focused:
            containerView.layer.borderColor = Colors.mainPink.color.cgColor
            containerView.layer.borderWidth = 1
        case .done:
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.borderWidth = 0
        case .error:
            containerView.layer.borderColor = Colors.mainRed.color.cgColor
            containerView.layer.borderWidth = 1
        }
    }
    
    func setDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }
    
    func setName(_ name: String) {
        textField.text = name
    }
}
