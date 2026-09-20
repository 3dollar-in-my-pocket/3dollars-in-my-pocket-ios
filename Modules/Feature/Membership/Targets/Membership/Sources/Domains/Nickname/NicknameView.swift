import UIKit

import Common
import DesignSystem

final class NicknameView: BaseView {
    private let tapGestureView = UITapGestureRecognizer()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(
            Icons.arrowLeft.image.withTintColor(Colors.systemWhite.color),
            for: .normal
        )
        return backButton
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: Assets.imageBungeoppang.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nicknameLabel1: UILabel = {
        let nicknameLabel1 = UILabel()
        nicknameLabel1.text = Strings.nicknameLabel1
        nicknameLabel1.font = Fonts.bold.font(size: 30)
        nicknameLabel1.textColor = Colors.systemWhite.color
        return nicknameLabel1
    }()
    
    let nicknameField: UITextField = {
        let nicknameField = UITextField()
        nicknameField.textAlignment = .center
        nicknameField.font = Fonts.bold.font(size: 30)
        nicknameField.textColor = Colors.mainPink.color
        nicknameField.returnKeyType = .done
        nicknameField.attributedPlaceholder = NSAttributedString(
            string: Strings.nicknamePlaceholder,
            attributes: [
                .foregroundColor: Colors.gray80.color as Any
            ]
        )
        nicknameField.tintColor = Colors.mainPink.color
        return nicknameField
    }()
    
    private let nicknameLabel2: UILabel = {
        let nicknameLabel2 = UILabel()
        nicknameLabel2.text = Strings.nicknameLabel2
        nicknameLabel2.font = Fonts.bold.font(size: 30)
        nicknameLabel2.textColor = Colors.systemWhite.color
        return nicknameLabel2
    }()
    
    let refreshButton: UIButton = {
        let refreshButton = UIButton()
        refreshButton.setImage(Icons.refresh.image, for: .normal)
        refreshButton.layer.borderColor = Colors.gray80.color.cgColor
        refreshButton.layer.borderWidth = 1
        refreshButton.layer.cornerRadius = 5
        refreshButton.clipsToBounds = true
        refreshButton.backgroundColor = Colors.gray90.color
        refreshButton.snp.makeConstraints {
            $0.size.equalTo(32)
        }
        return refreshButton
    }()
    
    private let warningImage: UIImageView = {
        let warningImage = UIImageView()
        warningImage.image = Icons.infomation.image.withTintColor(Colors.mainRed.color)
        warningImage.isHidden = true
        return warningImage
    }()
    
    private let warningLabel: PaddingLabel = {
        let warningLabel = PaddingLabel(topInset: 8, bottomInset: 8, leftInset: 12, rightInset: 12)
        warningLabel.text = Strings.nicknameAlreayExisted
        warningLabel.textColor = Colors.mainRed.color
        warningLabel.backgroundColor = Colors.mainRed.color.withAlphaComponent(0.1)
        warningLabel.layer.cornerRadius = 16
        warningLabel.layer.masksToBounds = true
        warningLabel.isHidden = true
        return warningLabel
    }()
    
    let signupButton: UIButton = {
        let signupButton = UIButton()
        signupButton.setTitle(Strings.nicknameSignup, for: .normal)
        signupButton.titleLabel?.font = Fonts.bold.font(size: 16)
        signupButton.setTitleColor(Colors.gray60.color, for: .disabled)
        signupButton.setTitleColor(Colors.systemWhite.color, for: .normal)
        signupButton.setBackgroundColor(Colors.gray80.color, for: .disabled)
        signupButton.setBackgroundColor(Colors.mainPink.color, for: .normal)
        signupButton.isEnabled = false
        return signupButton
    }()
    
    private let bottomBackground: UIView = {
        let bottomBackground = UIView()
        bottomBackground.backgroundColor = Colors.gray80.color
        return bottomBackground
    }()
    
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureView)
        nicknameField.delegate = self
        tapGestureView.addTarget(self, action: #selector(onTapBackground))
        
        addSubViews([
            backButton,
            imageView,
            nicknameLabel1,
            nicknameField,
            nicknameLabel2,
            refreshButton,
            warningImage,
            warningLabel,
            signupButton,
            bottomBackground
        ])
        setupKeyboardEvent()
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.width.height.equalTo(24)
        }

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nicknameLabel1.snp.top).offset(-14)
            $0.height.equalTo(96)
        }
        
        nicknameLabel1.snp.makeConstraints {
            $0.bottom.equalTo(nicknameField.snp.top).offset(-6)
            $0.centerX.equalToSuperview()
        }
        
        nicknameField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        nicknameLabel2.snp.makeConstraints {
            $0.top.equalTo(nicknameField.snp.bottom).offset(6)
            $0.centerX.equalToSuperview().offset(-18)
        }
        
        refreshButton.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel2.snp.trailing).offset(9)
            $0.centerY.equalTo(nicknameLabel2)
        }
        
        warningLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameLabel2.snp.bottom).offset(12)
            $0.height.equalTo(32)
        }
        
        warningImage.snp.makeConstraints {
            $0.centerY.equalTo(nicknameField)
            $0.leading.equalTo(nicknameField.snp.trailing).offset(4)
            $0.width.height.equalTo(20)
        }

        bottomBackground.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        signupButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomBackground.snp.top)
            $0.height.equalTo(64)
        }
    }
    
    func setHiddenWarning(isHidden: Bool) {
        warningImage.isHidden = isHidden
        warningLabel.isHidden = isHidden
        nicknameField.textColor = isHidden ? Colors.mainPink.color : Colors.mainRed.color
    }
    
    func setEnableSignupButton(_ isEnabled: Bool) {
        signupButton.isEnabled = isEnabled
        bottomBackground.backgroundColor = isEnabled ? Colors.mainPink.color : Colors.gray80.color
    }
    
    func hideKeyboard() {
        self.nicknameField.resignFirstResponder()
    }
    
    private func showKeyboard() {
        self.nicknameField.becomeFirstResponder()
    }
    
    private func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onShowKeyboard(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onHideKeyboard(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func onShowKeyboard(notification: NSNotification) {
        guard let keyboardFrameInfo
                = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        var keyboardFrame = keyboardFrameInfo.cgRectValue
        
        keyboardFrame = self.convert(keyboardFrame, from: nil)
        
        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        nicknameField.snp.remakeConstraints {
            $0.centerY.equalToSuperview().offset(-keyboardFrame.size.height/3)
            $0.centerX.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.signupButton.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
            self?.bottomBackground.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
            self?.layoutIfNeeded()
        }
    }
    
    @objc private func onHideKeyboard(notification: NSNotification) {
        nicknameField.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.signupButton.transform = .identity
            self?.bottomBackground.transform = .identity
            self?.layoutIfNeeded()
        }
    }
    
    @objc private func onTapBackground() {
        hideKeyboard()
    }
}

extension NicknameView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= 8
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        
        return true
    }
}
