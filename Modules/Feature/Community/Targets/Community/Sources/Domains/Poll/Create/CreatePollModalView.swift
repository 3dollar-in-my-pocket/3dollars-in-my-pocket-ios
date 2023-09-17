import UIKit

import Then
import Common
import DesignSystem

final class CreatePollModalView: BaseView {

    let backgroundView = UIView()

    let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .white
    }

    private let titleCountLabel = UILabel().then {
        $0.text = "0/20"
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }

    let titleTextField = UITextField().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.backgroundColor = .clear
        $0.textColor = Colors.gray100.color
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "투표 제목을 입력하세요",
            attributes: [
                .font: Fonts.semiBold.font(size: 20),
                .foregroundColor: Colors.gray30.color
            ])
    }

    let firstOptionTextField = CreatePollOptionTextField(
        padding: .init(top: 12, left: 16, bottom: 12, right: 16)
    ).then {
        $0.font = Fonts.regular.font(size: 14)
        $0.backgroundColor = Colors.gray10.color
        $0.textColor = Colors.gray100.color
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "ex) 슈붕",
            attributes: [
                .font: Fonts.regular.font(size: 14),
                .foregroundColor: Colors.gray40.color
            ])
        $0.layer.cornerRadius = 12
    }

    let secondOptionTextField = CreatePollOptionTextField(
        padding: .init(top: 12, left: 16, bottom: 12, right: 16)
    ).then {
        $0.font = Fonts.regular.font(size: 14)
        $0.backgroundColor = Colors.gray10.color
        $0.textColor = Colors.gray100.color
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "ex) 팥붕",
            attributes: [
                .font: Fonts.regular.font(size: 14),
                .foregroundColor: Colors.gray40.color
            ])
        $0.layer.cornerRadius = 12
    }

    let descriptionLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray100.color
        $0.numberOfLines = 0
        $0.text = "* 투표는 3일 동안만 진행돼요\n* 1일 1회만 올릴 수 있어요\n* 부적절한 내용일 경우 임의로 삭제될 수 있어요"
    }

    lazy var buttonStackView = UIStackView(
        arrangedSubviews: [cancelButton, createButton]
    ).then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(Colors.gray50.color, for: .normal)
        $0.titleLabel?.font = Fonts.semiBold.font(size: 14)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.gray40.color.cgColor
    }

    let createButton = UIButton().then {
        $0.setTitle("투표 만들기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = Fonts.semiBold.font(size: 14)
        $0.backgroundColor = Colors.gray30.color
        $0.layer.cornerRadius = 12
    }

    override func setup() {
        super.setup()

        containerView.addSubViews([
            titleTextField,
            titleCountLabel,
            firstOptionTextField,
            secondOptionTextField,
            descriptionLabel,
            buttonStackView
        ])

        addSubViews([
            backgroundView,
            containerView
        ])

        addKeyboardObservers()
    }

    override func bindConstraints() {
        super.bindConstraints()

        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.center.equalToSuperview()
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        firstOptionTextField.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        secondOptionTextField.snp.makeConstraints {
            $0.top.equalTo(firstOptionTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(secondOptionTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(20)
        }
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

        containerView.transform = CGAffineTransform(
            translationX: 0,
            y: -abs(containerView.frame.midY - keyboardFrame.cgRectValue.height)
        )
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        containerView.transform = .identity
    }
}

// MARK: UITextViewDelegate
extension CreatePollModalView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {

    }

    func textViewDidEndEditing(_ textView: UITextView) {

    }
}

final class CreatePollOptionTextField: UITextField {
    let textPadding: UIEdgeInsets

    init(padding: UIEdgeInsets) {
        self.textPadding = padding
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
