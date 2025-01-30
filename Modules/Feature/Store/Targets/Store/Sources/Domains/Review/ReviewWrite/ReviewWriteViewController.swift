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
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.arrowLeft.image.withTintColor(Colors.gray100.color), for: .normal)
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ReviewList.title
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        
        return label
    }()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private lazy var feedbackSelectionView = ReviewFeedbackSelectionView(viewModel.output.feedbackSelectionViewModel)
    private let contentView = ReviewWriteContentView()
    private let photoListView = ReviewPhotoListView()
    private let completeButton = UIButton().then {
        $0.isEnabled = false
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
            backButton,
            titleLabel,
            scrollView,
            completeButton,
            bottomBackgroundView
        ])
        
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
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
            $0.bottom.equalToSuperview().inset(30)
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
        
        backButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: ReviewWriteViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        contentView.ratingInputView.ratingPublisher
            .subscribe(viewModel.input.didTapRating)
            .store(in: &cancellables)
        
        contentView.textView
            .textPublisher
            .filter { $0 != Strings.ReviewBottomSheet.placeholder }
            .subscribe(viewModel.input.inputReview)
            .store(in: &cancellables)
        
        photoListView.didTapUploadPhoto
            .subscribe(viewModel.input.didTapUploadPhoto)
            .store(in: &cancellables)
        
        photoListView.removeImage
            .subscribe(viewModel.input.removeImage)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isEnableWriteButton
            .main
            .sink { [weak self] isEnabled in
                guard let self else { return }
                
                completeButton.backgroundColor = isEnabled ? Colors.mainPink.color : Colors.gray30.color
                bottomBackgroundView.backgroundColor = isEnabled ? Colors.mainPink.color : Colors.gray30.color
                completeButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)
        
        viewModel.output.onSuccessWriteReview
            .main
            .sink { [weak self] isEnabled in
                guard let self else { return }
                
                ToastManager.shared.show(message: "리뷰가 등록되었습니다!")
                navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.errorAlert
            .main
            .withUnretained(self)
            .sink { (owner: ReviewWriteViewController, error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                guard let self else { return }
                
                switch route {
                case .dismiss:
                    navigationController?.popViewController(animated: true)
                case .uploadPhoto(let viewModel):
                    let viewController = UploadPhotoViewController.instance(viewModel: viewModel)
                    present(viewController, animated: true)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.imageUrls
            .main
            .sink { [weak self] in
                self?.photoListView.setImages($0.map { $0.url })
            }
            .store(in: &cancellables)
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
