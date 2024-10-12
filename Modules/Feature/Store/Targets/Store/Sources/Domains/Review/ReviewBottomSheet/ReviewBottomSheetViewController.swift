import UIKit
import Combine

import Common
import DesignSystem
import PanModal
import Log

final class ReviewBottomSheetViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let reviewBottomSheet = ReviewBottomSheet()
    private let viewModel: ReviewBottomSheetViewModel
    
    private var keyboardHeight: CGFloat = .zero
    
    static func instance(viewModel: ReviewBottomSheetViewModel) -> ReviewBottomSheetViewController {
        return ReviewBottomSheetViewController(viewModel: viewModel)
    }
    
    init(viewModel: ReviewBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        view = reviewBottomSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardObservers()
    }
    
    override func bindEvent() {
        reviewBottomSheet.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        reviewBottomSheet.ratingInputView.ratingPublisher
            .subscribe(viewModel.input.didTapRating)
            .store(in: &cancellables)
        
        reviewBottomSheet.textView
            .textPublisher
            .filter { $0 != Strings.ReviewBottomSheet.placeholder }
            .subscribe(viewModel.input.inputReview)
            .store(in: &cancellables)
        
        reviewBottomSheet.writeButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapWrite)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.rating
            .main
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewController, rating) in
                owner.reviewBottomSheet.setRating(rating)
            }
            .store(in: &cancellables)
        
        viewModel.output.contents
            .main
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewController, contents) in
                owner.reviewBottomSheet.setContents(contents)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableWriteButton
            .main
            .assign(to: \.isEnabled, on: reviewBottomSheet.writeButton)
            .store(in: &cancellables)
        
        viewModel.output.errorAlert
            .main
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewController, error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewController, route) in
                switch route {
                case .dismiss:
                    owner.dismiss(animated: true)
                }
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
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        keyboardHeight = .zero
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
}

extension ReviewBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(316 - UIUtils.bottomSafeAreaInset + keyboardHeight)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(316 - UIUtils.bottomSafeAreaInset + keyboardHeight)
    }
    
    var cornerRadius: CGFloat {
        return 24
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
