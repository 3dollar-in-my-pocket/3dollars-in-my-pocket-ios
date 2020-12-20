import UIKit

protocol ReviewModalDelegate: class {
    func onTapClose()
    
    func onReviewSuccess()
}

class ReviewModalVC: BaseVC {
    
    weak var deleagete: ReviewModalDelegate?
    var storeId: Int!
    
    private lazy var reviewModalView = ReviewModalView(frame: self.view.frame).then {
        $0.delegate = self
    }
    
    static func instance() -> ReviewModalVC {
        return ReviewModalVC(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func viewDidLoad() {
        view = reviewModalView
        reviewModalView.reviewTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func bindViewModel() {
        
    }
    
    private func saveReview() {
      let review = Review.init(rating: reviewModalView.rating, contents: reviewModalView.reviewTextView.text)
      ReviewService().saveReview(review: review, storeId: storeId)
        .subscribe(
          onNext: { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            self.deleagete?.onReviewSuccess()
          },
          onError: { [weak self] error in
            guard let self = self else { return }
            if let httpError = error as? HTTPError {
              self.showHTTPErrorAlert(error: httpError)
            }
          })
        .disposed(by: disposeBag)
    }
    
    private func isValidateReview(text: String) -> Bool {
        if text == "리뷰를 남겨주세요! (100자 이내)" {
            return false
        }
        
        return !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo as? [String:Any] else {return}
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.cgRectValue.height)
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.transform = .identity
    }
}

extension ReviewModalVC: ReviewModalViewDelegate {
    func onTapClose() {
        self.deleagete?.onTapClose()
    }
    
    func onTapRegister() {
        if self.isValidateReview(text: reviewModalView.reviewTextView.text) {
            self.saveReview()
        } else {
            AlertUtils.show(controller: self, message: "내용을 입력해주세요.")
        }
    }
}


extension ReviewModalVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "리뷰를 남겨주세요! (100자 이내)" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "리뷰를 남겨주세요! (100자 이내)"
            textView.textColor = UIColor.init(r: 200, g: 200, b: 200)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
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
            self.reviewModalView.reviewTextView.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
        } else {
            self.reviewModalView.reviewTextView.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        }
        return count <= 100
    }
}
