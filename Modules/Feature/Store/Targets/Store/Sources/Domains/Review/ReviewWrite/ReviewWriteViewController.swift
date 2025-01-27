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
    private let containerView = UIView()
    
    private lazy var feedbackSelectionView = ReviewFeedbackSelectionView(viewModel.output.feedbackSelectionViewModel)
    private let contentView = ReviewWriteContentView()
    private let photoListView = ReviewPhotoListView()
    private let completeButton = UIButton().then {
//        $0.isEnabled = false
        $0.backgroundColor = Colors.mainPink.color
        $0.setTitle(Strings.BossStoreFeedback.sendFeedback, for: .normal)
        $0.titleLabel?.font = Fonts.bold.font(size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    private let bottomBackgroundView = UIView().then {
        $0.backgroundColor = Colors.mainPink.color
    }
    
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
        viewModel.input.load.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubViews([
            scrollView,
            completeButton,
            bottomBackgroundView
        ])
        
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(completeButton.snp.top)
        }
        
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        containerView.addSubview(feedbackSelectionView)
        containerView.addSubview(contentView)
        containerView.addSubview(photoListView)
        
        feedbackSelectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(feedbackSelectionView.snp.bottom).offset(52)
            $0.leading.trailing.equalToSuperview()
        }
        photoListView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        completeButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomBackgroundView.snp.top)
            $0.height.equalTo(64)
        }

        bottomBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    override func bindEvent() {
        completeButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapCompleteButton)
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
