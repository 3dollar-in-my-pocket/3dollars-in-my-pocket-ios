import UIKit

import RxSwift
import RxCocoa

final class BookmarkEditView: BaseView {
    private let tapGesture = UITapGestureRecognizer()
    
    let backButton = UIButton().then {
        $0.setImage(
            R.image.ic_back()?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "bookmark_edit_title".localized
        $0.font = .semiBold(size: 16)
        $0.textColor = .white
    }
    
    private let titleCountLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray50()
    }
    
    private let titleTextView = UITextView().then {
        $0.textColor = .white
        $0.font = .regular(size: 24)
        $0.backgroundColor = .clear
        $0.textContainer.lineBreakMode = .byTruncatingTail
        $0.textContainer.maximumNumberOfLines = 2
    }
    
    private let descriptionCountLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray50()
    }
    
    private let descriptionTextView = UITextView().then {
        $0.textColor = .white
        $0.font = .regular(size: 12)
        $0.backgroundColor = .clear
        $0.textContainer.lineBreakMode = .byTruncatingTail
        $0.textContainer.maximumNumberOfLines = 6
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("bookmark_edit_save".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = R.color.red()
    }
    
    private let safeAreaView = UIView().then {
        $0.backgroundColor = R.color.red()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        self.addGestureRecognizer(self.tapGesture)
        self.backgroundColor = R.color.gray100()
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.titleCountLabel,
            self.titleTextView,
            self.descriptionCountLabel,
            self.descriptionTextView,
            self.safeAreaView,
            self.saveButton
        ])
        
        self.tapGesture.rx.event
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.endEditing(false)
            })
            .disposed(by: self.disposeBag)
        self.titleTextView.rx.text.orEmpty
            .asDriver()
            .map { "\($0.trimmingCharacters(in: .whitespacesAndNewlines).count)/20" }
            .drive(self.titleCountLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.descriptionTextView.rx.text.orEmpty
            .asDriver()
            .map { "\($0.trimmingCharacters(in: .whitespacesAndNewlines).count)/150" }
            .drive(self.descriptionCountLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.setupKeyboardEvent()
        self.titleTextView.delegate = self
        self.descriptionTextView.delegate = self
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.titleCountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.backButton.snp.bottom).offset(37)
        }
        
        self.titleTextView.snp.makeConstraints { make in
            make.left.equalTo(self.titleCountLabel)
            make.top.equalTo(self.titleCountLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(80)
        }
        
        self.descriptionCountLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleCountLabel)
            make.top.equalTo(self.titleTextView.snp.bottom).offset(24)
        }
        
        self.descriptionTextView.snp.makeConstraints { make in
            make.left.equalTo(self.titleTextView)
            make.right.equalTo(self.titleTextView)
            make.top.equalTo(self.descriptionCountLabel.snp.bottom).offset(8)
            make.height.equalTo(110)
        }
        
        self.saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(64)
        }
        
        self.safeAreaView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
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
        
        keyboardFrame = self.convert(keyboardFrame, from: nil)
        
        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.safeAreaView.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
            self?.saveButton.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
        }
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.safeAreaView.transform = .identity
            self?.saveButton.transform = .identity
        }
    }
}

extension BookmarkEditView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let textFieldText = textView.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
          return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + text.count
        var newLinesCount = textFieldText.components(separatedBy: CharacterSet.newlines).count - 1
        
        if text == "\n" {
            newLinesCount += 1
        }
        
        if textView == self.titleTextView {
            return count <= 20 && newLinesCount < 2
        } else {
            return count <= 150 && newLinesCount < 6
        }
    }
}
