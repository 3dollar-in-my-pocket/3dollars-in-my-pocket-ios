import UIKit
import RxSwift

protocol ReviewModalDelegate: class {
  
  func onTapClose()
  func onReviewSuccess()
}

class ReviewModalVC: BaseVC {
  
  weak var deleagete: ReviewModalDelegate?
  
  private let viewModel: ReviewModalViewModel
  private let review: Review?
  
  private lazy var reviewModalView = ReviewModalView(frame: self.view.frame)
  
  
  init(storeId: Int, review: Review?) {
    self.viewModel = ReviewModalViewModel(
      reviewService: ReviewService(),
      storeId: storeId,
      review: review
    )
    self.review = review
    super.init(nibName: nil, bundle: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeId: Int, review: Review? = nil) -> ReviewModalVC {
    return ReviewModalVC(storeId: storeId, review: review).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = reviewModalView
    
    self.addObservers()
    if let review = self.review {
      self.reviewModalView.bind(review: review)
    }
  }
  
  override func bindViewModel() {
    // Bind input
    self.reviewModalView.star1.rx.tap
      .map { 1 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star2.rx.tap
      .map { 2 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star3.rx.tap
      .map { 3 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star4.rx.tap
      .map { 4 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.star5.rx.tap
      .map { 5 }
      .observeOn(MainScheduler.instance)
      .do(onNext: self.reviewModalView.onTapStackView)
      .bind(to: self.viewModel.input.rating)
      .disposed(by: disposeBag)
    
    self.reviewModalView.reviewTextView.rx.text.orEmpty
      .bind(to: self.viewModel.input.contents)
      .disposed(by: disposeBag)
    
    self.reviewModalView.registerButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapRegister)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.reviewModalView.showLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.dismissOnSaveReview
      .observeOn(MainScheduler.instance)
      .bind { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
        self?.deleagete?.onReviewSuccess()
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.showHTTPErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
    
    self.viewModel.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.reviewModalView.closeButton.rx.tap
      .observeOn(MainScheduler.instance)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .review_write_close_button_clicked, page: .review_write)
      })
      .bind(onNext: self.dismissModal)
      .disposed(by: disposeBag)
    
    self.reviewModalView.tapBackground.rx.event.bind { [weak self] _ in
      self?.dismissModal()
    }
    .disposed(by: disposeBag)
  }
  
  private func addObservers() {
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
  
  private func dismissModal() {
    self.dismiss(animated: true, completion: nil)
    self.deleagete?.onTapClose()
  }
  
  @objc func keyboardWillShow(_ sender: Notification) {
    guard let userInfo = sender.userInfo as? [String:Any] else {return}
    guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
    
    self.reviewModalView.containerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.cgRectValue.height)
  }
  
  @objc func keyboardWillHide(_ sender: Notification) {
    self.reviewModalView.containerView.transform = .identity
  }
}
