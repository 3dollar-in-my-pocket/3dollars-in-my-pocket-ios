import UIKit

class ReviewModalView: BaseView {
  
  let tapBackground = UITapGestureRecognizer()
  
  let backgroundView = UIView()
  
  let containerView = UIView().then {
    $0.layer.cornerRadius = 40
    $0.backgroundColor = .white
  }
  
  let titleLabel = UILabel().then {
    $0.text = "review_modal_title".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 24)
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  let closeButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_close_24"), for: .normal)
  }
  
  let star1 = UIButton().then {
    $0.imageView?.contentMode = .scaleAspectFill
    $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
    $0.showsTouchWhenHighlighted = false
  }
  
  let star2 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
  }
  
  let star3 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
  }
  
  let star4 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
  }
  
  let star5 = UIButton().then {
    $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
    $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
  }
  
  let stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .leading
    $0.backgroundColor = .clear
    $0.spacing = 8
  }
  
  let stackContainer = UIView().then {
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
    $0.layer.borderWidth = 1
  }
  
  let reviewTextView = UITextView().then {
    $0.text = "review_modal_placeholder".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.contentInset = UIEdgeInsets(top: 8, left: 5, bottom: 10, right: 0)
    $0.backgroundColor = .clear
    $0.textColor = UIColor(r: 200, g: 200, b: 200)
    $0.returnKeyType = .done
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
  }
  
  let registerButton = UIButton().then {
    $0.setTitle("review_modal_register".localized, for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = UIFont(name: "SpoqaHanSans-Bold", size: 16)
    $0.backgroundColor = UIColor(r: 238, g: 98, b: 76)
    $0.layer.cornerRadius = 14
  }
  
  
  override func setup() {
    self.backgroundView.addGestureRecognizer(self.tapBackground)
    self.stackView.addArrangedSubview(star1)
    self.stackView.addArrangedSubview(star2)
    self.stackView.addArrangedSubview(star3)
    self.stackView.addArrangedSubview(star4)
    self.stackView.addArrangedSubview(star5)
    containerView.addSubViews(
      registerButton, reviewTextView, stackContainer,
      stackView, titleLabel, closeButton
    )
    addSubViews(backgroundView, containerView)
    self.reviewTextView.delegate = self
  }
  
  override func bindConstraints() {
    self.backgroundView.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }
    
    self.containerView.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
      make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
      make.top.equalTo(self.titleLabel).offset(-24)
    }
    
    self.registerButton.snp.makeConstraints { (make) in
      make.left.equalTo(containerView).offset(24)
      make.right.equalTo(containerView).offset(-24)
      make.bottom.equalTo(containerView).offset(-24)
      make.height.equalTo(48)
    }
    
    self.reviewTextView.snp.makeConstraints { (make) in
      make.left.right.equalTo(registerButton)
      make.bottom.equalTo(registerButton.snp.top).offset(-32)
      make.height.equalTo(88)
    }
    
    self.stackContainer.snp.makeConstraints { (make) in
      make.left.right.equalTo(registerButton)
      make.bottom.equalTo(reviewTextView.snp.top).offset(-14)
      make.height.equalTo(48)
    }
    
    self.star1.snp.makeConstraints { (make) in
      make.width.height.equalTo(32)
    }
    
    self.star2.snp.makeConstraints { (make) in
      make.width.height.equalTo(32)
    }
    
    self.star3.snp.makeConstraints { (make) in
      make.width.height.equalTo(32)
    }
    
    self.star4.snp.makeConstraints { (make) in
      make.width.height.equalTo(32)
    }
    
    self.star5.snp.makeConstraints { (make) in
      make.width.height.equalTo(32)
    }
    
    self.stackView.snp.makeConstraints { (make) in
      make.centerY.equalTo(stackContainer)
      make.left.equalTo(stackContainer).offset(14)
    }
    
    self.titleLabel.snp.makeConstraints { (make) in
      make.left.equalTo(registerButton)
      make.bottom.equalTo(stackContainer.snp.top).offset(-24)
    }
    
    self.closeButton.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel)
      make.right.equalTo(registerButton)
      make.width.height.equalTo(24)
    }
  }
  
  func onTapStackView(tappedIndex: Int) {
    GA.shared.logEvent(event: .star_button_clicked, page: .review_write)
    stackContainer.layer.borderColor = UIColor(r: 243, g: 162, b: 169).cgColor
    for index in stackView.arrangedSubviews.indices {
      if let button = stackView.arrangedSubviews[index] as? UIButton {
        button.isSelected = (index <= tappedIndex - 1)
      }
    }
  }
  
  func bind(review: Review) {
    self.titleLabel.text = "review_modal_modify_title".localized
    self.registerButton.setTitle("review_modal_modify".localized, for: .normal)
    self.onTapStackView(tappedIndex: review.rating)
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
    if textView.text == "review_modal_placeholder".localized {
      textView.text = ""
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
      textView.text = "review_modal_placeholder".localized
      textView.textColor = UIColor(r: 200, g: 200, b: 200)
    }
  }
  
  func textView(
    _ textView: UITextView,
    shouldChangeTextIn range: NSRange,
    replacementText text: String
  ) -> Bool {
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
      self.reviewTextView.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
    } else {
      self.reviewTextView.layer.borderColor = UIColor(r: 243, g: 162, b: 169).cgColor
    }
    
    return count <= 100
  }
}

