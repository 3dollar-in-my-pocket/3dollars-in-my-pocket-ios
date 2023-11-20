import UIKit
import Combine

import Common

import PanModal

final class ReportReviewBottomSheetViewController: BaseViewController {
    private let reportReviewBottomSheet = ReportReviewBottomSheet()
    private let viewModel: ReportReviewBottomSheetViewModel
    private lazy var datasource = ReportReviewDataSource(viewModel: viewModel, collectionView: reportReviewBottomSheet.collectionView)
    
    static func instance(viewModel: ReportReviewBottomSheetViewModel) -> ReportReviewBottomSheetViewController {
        return ReportReviewBottomSheetViewController(viewModel: viewModel)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(viewModel: ReportReviewBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = reportReviewBottomSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardEvent()
        reportReviewBottomSheet.collectionView.dataSource = datasource
    }
    
    override func bindEvent() {
        reportReviewBottomSheet.closeButton.controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: ReportReviewBottomSheetViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        reportReviewBottomSheet.reportButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReport)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.sectionItems
            .main
            .withUnretained(self)
            .sink { (owner: ReportReviewBottomSheetViewController, sectionItems: [ReportReviewSectionItem]) in
                let collectionViewHeight = owner.reportReviewBottomSheet.getCollectionViewHeight(sectionItems: sectionItems)
                
                owner.reportReviewBottomSheet.collectionView.snp.updateConstraints {
                    $0.height.equalTo(collectionViewHeight)
                }
                
                DispatchQueue.main.async {
                    owner.reportReviewBottomSheet.layoutIfNeeded()
                    owner.datasource.reloadData(sectionItems: sectionItems) {
                        owner.panModalSetNeedsLayoutUpdate()
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableReport
            .main
            .assign(to: \.isEnabled, on: reportReviewBottomSheet.reportButton)
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: ReportReviewBottomSheetViewController, route: ReportReviewBottomSheetViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: ReportReviewBottomSheetViewController, error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: ReportReviewBottomSheetViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true, completion: nil)
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

        keyboardFrame = view.convert(keyboardFrame, from: nil)

        let window = UIApplication.shared.windows.first
        let bottomPadding = UIUtils.bottomSafeAreaInset

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.reportReviewBottomSheet.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
            self?.reportReviewBottomSheet.transform = .init(
                translationX: 0,
                y: -keyboardFrame.size.height + bottomPadding
            )
        }
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.reportReviewBottomSheet.transform = .identity
        }
    }
}

extension ReportReviewBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        reportReviewBottomSheet.collectionView
    }
    
    var shortFormHeight: PanModalHeight {
        guard let sectionItems = datasource.snapshot().sectionIdentifiers.first?.items else { return .maxHeight }
        let collectionViewHeight = reportReviewBottomSheet.getCollectionViewHeight(sectionItems: sectionItems)
        
        return .contentHeight(collectionViewHeight + 164)
    }
    
    var longFormHeight: PanModalHeight {
        guard let sectionItems = datasource.snapshot().sectionIdentifiers.first?.items else { return .maxHeight }
        let collectionViewHeight = reportReviewBottomSheet.getCollectionViewHeight(sectionItems: sectionItems)
        
        return .contentHeight(collectionViewHeight + 164)
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
