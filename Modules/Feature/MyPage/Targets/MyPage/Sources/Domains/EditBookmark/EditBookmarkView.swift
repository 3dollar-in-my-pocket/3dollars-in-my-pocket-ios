import UIKit

import Common
import DesignSystem

final class EditBookmarkView: BaseView {
    private let tapBackground = UITapGestureRecognizer()
    
    let backButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowLeft.image.withTintColor(Colors.systemWhite.color)
        
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.text = "정보 수정하기"
        
        return label
    }()
    
    let editTitleView = EditBookmarkTitleView()
    
    let editDescriptionVIew = EditBookmarkDescriptionView()
    
    let saveButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("저장하기", for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = Colors.mainPink.color
        return button
    }()
    
    private let bottomBackgroundView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.mainPink.color
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        addGestureRecognizer(tapBackground)
        backgroundColor = Colors.gray100.color
        addSubViews([
            backButton,
            titleLabel,
            editTitleView,
            editDescriptionVIew,
            saveButton,
            bottomBackgroundView
        ])
        setupKeyboardEvent()
        
        tapBackground.addTarget(self, action: #selector(didTapBackground))
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        editTitleView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(27)
            $0.trailing.equalToSuperview()
        }
        
        editDescriptionVIew.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(editTitleView.snp.bottom).offset(41)
            $0.trailing.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        bottomBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setEnable(_ isEnable: Bool) {
        let backgroundColor = isEnable ? Colors.mainPink.color : Colors.gray80.color
        
        saveButton.backgroundColor = backgroundColor
        saveButton.isEnabled = isEnable
        bottomBackgroundView.backgroundColor = backgroundColor
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
    
    @objc func onShowKeyboard(notification: NSNotification) {
        guard let keyboardFrameInfo
                = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        var keyboardFrame = keyboardFrameInfo.cgRectValue

        keyboardFrame = convert(keyboardFrame, from: nil)

        let window = UIApplication.shared.windows.first
        let bottomPadding = UIUtils.bottomSafeAreaInset

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.saveButton.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
            self?.bottomBackgroundView.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
        }
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.saveButton.transform = .identity
            self?.bottomBackgroundView.transform = .identity
        }
    }
    
    @objc func didTapBackground() {
        endEditing(true)
    }
}
