import UIKit
import Combine

import Common
import DesignSystem
import PanModal
import Log

final class ReviewWriteViewController: BaseViewController {
    override var screenName: ScreenName {
        return .accountInfo // TODO
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var feedbackSelectionView = ReviewFeedbackSelectionView(viewModel.output.feedbackSelectionViewModel)
    private let reviewBottomSheet = ReviewBottomSheet()
    
    private let viewModel: ReviewWriteViewModel
    
    private var keyboardHeight: CGFloat = .zero
    
    static func instance(viewModel: ReviewWriteViewModel) -> ReviewWriteViewController {
        return ReviewWriteViewController(viewModel: viewModel)
    }
    
    init(viewModel: ReviewWriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        addKeyboardObservers()
//        viewModel.input.load.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.addSubview(feedbackSelectionView)
        contentView.addSubview(reviewBottomSheet)
        
        feedbackSelectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        reviewBottomSheet.snp.makeConstraints {
            $0.top.equalTo(feedbackSelectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    override func bindEvent() {
        reviewBottomSheet.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: ReviewWriteViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
//        reviewBottomSheet.ratingInputView.ratingPublisher
//            .subscribe(viewModel.input.didTapRating)
//            .store(in: &cancellables)
//        
//        reviewBottomSheet.textView
//            .textPublisher
//            .filter { $0 != Strings.ReviewBottomSheet.placeholder }
//            .subscribe(viewModel.input.inputReview)
//            .store(in: &cancellables)
//        
//        reviewBottomSheet.writeButton.tapPublisher
//            .throttleClick()
//            .subscribe(viewModel.input.didTapWrite)
//            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
//        viewModel.output.rating
//            .main
//            .withUnretained(self)
//            .sink { (owner: ReviewWriteViewController, rating) in
//                owner.reviewBottomSheet.setRating(rating)
//            }
//            .store(in: &cancellables)
//        
//        viewModel.output.contents
//            .main
//            .withUnretained(self)
//            .sink { (owner: ReviewWriteViewController, contents) in
//                owner.reviewBottomSheet.setContents(contents)
//            }
//            .store(in: &cancellables)
//        
//        viewModel.output.isEnableWriteButton
//            .main
//            .assign(to: \.isEnabled, on: reviewBottomSheet.writeButton)
//            .store(in: &cancellables)
//        
//        viewModel.output.errorAlert
//            .main
//            .withUnretained(self)
//            .sink { (owner: ReviewWriteViewController, error) in
//                owner.showErrorAlert(error: error)
//            }
//            .store(in: &cancellables)
//        
//        viewModel.output.route
//            .main
//            .withUnretained(self)
//            .sink { (owner: ReviewWriteViewController, route) in
//                switch route {
//                case .dismiss:
//                    owner.dismiss(animated: true)
//                }
//            }
//            .store(in: &cancellables)
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
        
        keyboardHeight = keyboardFrame.cgRectValue.height
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        keyboardHeight = .zero
    }
}
