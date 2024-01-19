import UIKit
import Combine

import Common

final class EditNicknameField: BaseView {
    let textChanged = PassthroughSubject<String, Never>()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.bold.font(size: 30)
        label.text = Strings.EditNickname.Description.top
        label.setLineHeight(lineHeight: 42)
        label.textAlignment = .center
        
        return label
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.bold.font(size: 30)
        textField.textColor = Colors.mainPink.color
        textField.textAlignment = .center
        textField.tintColor = Colors.mainPink.color
        
        return textField
    }()
    
    private let warningIcon: UIImageView = {
        let imageView = UIImageView()
        let image = Icons.infomation.image.withRenderingMode(.alwaysTemplate)
        
        imageView.image = image
        imageView.tintColor = Colors.mainRed.color
        imageView.isHidden = true
        return imageView
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.bold.font(size: 30)
        label.text = Strings.EditNickname.Description.bottom
        label.setLineHeight(lineHeight: 42)
        label.textAlignment = .center
        
        return label
    }()
    
    override func setup() {
        addSubViews([
            topLabel,
            textField,
            warningIcon,
            bottomLabel
        ])
        
        textField.controlPublisher(for: .editingChanged)
            .withUnretained(self)
            .sink { (owner: EditNicknameField, _) in
                let text = owner.textField.text ?? ""
                
                owner.textChanged.send(text)
            }
            .store(in: &cancellables)
    }
    
    override func bindConstraints() {
        topLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(topLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.lessThanOrEqualToSuperview().offset(-40)
        }
        
        warningIcon.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.leading.equalTo(textField.snp.trailing).offset(6)
            $0.size.equalTo(16)
        }
        
        bottomLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(textField.snp.bottom).offset(2)
            $0.trailing.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.top.equalTo(topLabel).priority(.high)
            $0.bottom.equalTo(bottomLabel).priority(.high)
        }
    }
    
    func setHiddenWarning(_ isHidden: Bool) {
        updateTextFieldWidth(sizeToFit: !isHidden)
        textField.textColor = isHidden ? Colors.mainPink.color : Colors.mainRed.color
        warningIcon.isHidden = isHidden
    }
    
    private func updateTextFieldWidth(sizeToFit: Bool) {
        guard let text = textField.text else { return }
        
        if sizeToFit {
            let nsString = NSString(string: text)
            let width = nsString.size(withAttributes: [.font: Fonts.bold.font(size: 30)]).width
            
            DispatchQueue.main.async {
                self.textField.snp.remakeConstraints {
                    $0.top.equalTo(self.topLabel.snp.bottom)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(50)
                    $0.width.lessThanOrEqualToSuperview().offset(-40)
                    $0.width.equalTo(width)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.textField.snp.remakeConstraints {
                    $0.top.equalTo(self.topLabel.snp.bottom)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(50)
                    $0.width.lessThanOrEqualToSuperview().offset(-40)
                }
            }
        }
    }
}
