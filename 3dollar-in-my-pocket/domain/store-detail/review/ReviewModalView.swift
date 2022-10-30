import UIKit

import Base

final class ReviewModalView: BaseView {
    fileprivate let tapBackground = UITapGestureRecognizer()
    
    private let backgroundView = UIView()
    
    let containerView = UIView().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = R.string.localization.review_modal_title()
        $0.font = .light(size: 24)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(R.image.ic_close_24(), for: .normal)
    }
    
    let ratingInputView = RatingInputView()
    
    let reviewTextView = UITextView().then {
        $0.text = R.string.localization.review_modal_placeholder()
        $0.font = .regular(size: 16)
        $0.contentInset = UIEdgeInsets(top: 8, left: 5, bottom: 10, right: 0)
        $0.backgroundColor = .clear
        $0.textColor = UIColor(r: 200, g: 200, b: 200)
        $0.returnKeyType = .done
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
    }
    
    let registerButton = UIButton().then {
        $0.setTitle(R.string.localization.review_modal_register(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.backgroundColor = UIColor(r: 238, g: 98, b: 76)
        $0.layer.cornerRadius = 14
    }
    
    override func setup() {
        self.backgroundView.addGestureRecognizer(self.tapBackground)
        self.containerView.addSubViews([
            self.registerButton,
            self.reviewTextView,
            self.titleLabel,
            self.closeButton,
            self.ratingInputView
        ])
        self.addSubViews([
            self.backgroundView,
            self.containerView
        ])
        self.reviewTextView.delegate = self
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            make.top.equalTo(self.titleLabel).offset(-24)
        }
        
        self.registerButton.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
            make.bottom.equalTo(containerView).offset(-24)
            make.height.equalTo(48)
        }
        
        self.reviewTextView.snp.makeConstraints { make in
            make.left.right.equalTo(registerButton)
            make.bottom.equalTo(registerButton.snp.top).offset(-32)
            make.height.equalTo(88)
        }
        
        self.ratingInputView.snp.makeConstraints { make in
            make.left.right.equalTo(registerButton)
            make.bottom.equalTo(reviewTextView.snp.top).offset(-14)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(registerButton)
            make.bottom.equalTo(ratingInputView.snp.top).offset(-24)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.right.equalTo(registerButton)
            make.width.height.equalTo(24)
        }
    }
    
    func bind(review: Review) {
        self.titleLabel.text = R.string.localization.review_modal_modify_title()
        self.registerButton.setTitle(R.string.localization.review_modal_modify(), for: .normal)
        self.ratingInputView.onTapStackView(tappedIndex: review.rating)
        self.reviewTextView.text = review.contents
        self.reviewTextView.textColor = .black
        
        if review.contents.isEmpty {
            self.reviewTextView.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
        } else {
            self.reviewTextView.layer.borderColor = UIColor(r: 243, g: 162, b: 169).cgColor
        }
    }
}

// MARK: UITextViewDelegate
extension ReviewModalView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == R.string.localization.review_modal_placeholder() {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = R.string.localization.review_modal_placeholder()
            textView.textColor = UIColor(r: 200, g: 200, b: 200)
        }
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        guard let textFieldText = textView.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + text.count
        
        if count == 0 {
            self.reviewTextView.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
        } else {
            self.reviewTextView.layer.borderColor = UIColor(r: 243, g: 162, b: 169).cgColor
        }
        
        return count <= 100
    }
}
