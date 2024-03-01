import UIKit

import Common
import DesignSystem

final class EditNicknameView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowLeft.image.withTintColor(Colors.systemWhite.color)
        
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.text = Strings.EditNickname.title
        return label
    }()
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = Images.imageBungeoppang.image
        return imageView
    }()
    
    let nicknameField = EditNicknameField()
    
    private let warningLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 8, bottomInset: 8, leftInset: 12, rightInset: 12)
        
        label.backgroundColor = Colors.mainRed.color.withAlphaComponent(0.1)
        label.textColor = Colors.mainRed.color
        label.text = Strings.EditNickname.warning
        label.font = Fonts.medium.font(size: 12)
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    private let bottomBackgroundView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gray80.color
        return view
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(Strings.EditNickname.edit, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        button.setTitleColor(Colors.gray60.color, for: .disabled)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.setBackgroundColor(Colors.gray80.color, for: .disabled)
        button.setBackgroundColor(Colors.mainPink.color, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.isEnabled = false
        return button
    }()
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        
        addSubViews([
            backButton,
            titleLabel,
            logoImage,
            nicknameField,
            warningLabel,
            bottomBackgroundView,
            editButton
        ])
        
        addKeyboardObservers()
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        bottomBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        editButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomBackgroundView.snp.top)
            $0.height.equalTo(64)
        }
        
        nicknameField.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        warningLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
            $0.top.equalTo(nicknameField.snp.bottom).offset(12)
        }
        
        logoImage.snp.makeConstraints {
            $0.width.equalTo(130)
            $0.height.equalTo(78)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nicknameField.snp.top).offset(-24)
        }
    }
    
    func setEnableEditButton(_ isEnable: Bool) {
        editButton.isEnabled = isEnable
        bottomBackgroundView.backgroundColor = isEnable ? Colors.mainPink.color : Colors.gray80.color
    }
    
    func setCurrentNickname(_ nickname: String) {
        let attributedString = NSAttributedString(string: nickname, attributes: [
            .foregroundColor : Colors.gray60.color,
            .font: Fonts.bold.font(size: 30)
        ])
        
        nicknameField.textField.attributedPlaceholder = attributedString
        nicknameField.sizeToFit()
    }
    
    func setHiddenWarning(_ isHidden: Bool) {
        nicknameField.setHiddenWarning(isHidden)
        layoutIfNeeded()
        warningLabel.isHidden = isHidden
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo as? [String: Any] else { return }
        guard let keyboardFrame
                = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        UIView.animate(withDuration: 0.3) {
            self.editButton.transform = CGAffineTransform(
                translationX: 0,
                y: -keyboardFrame.cgRectValue.height + bottomPadding
            )
        }
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.editButton.transform = .identity
        }
    }
}
