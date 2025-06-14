import UIKit

import Common
import DesignSystem
import Log

public final class ReviewListViewControlelr: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let reviewListView = ReviewListView()
    private let viewModel: ReviewListViewModel
    private lazy var datasource = ReviewListDatasource(
        collection: reviewListView.collectionView,
        viewModel: viewModel,
        vc: self
    )
    
    public static func instance(viewModel: ReviewListViewModel) -> ReviewListViewControlelr {
        return ReviewListViewControlelr(viewModel: viewModel)
    }
    
    init(viewModel: ReviewListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = reviewListView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.viewDidLoad.send(())
    }
    
    public override func bindEvent() {
        reviewListView.backButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: ReviewListViewControlelr, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    public override func bindViewModelInput() {
        reviewListView.subtabStackView.sortTypePublisher
            .subscribe(viewModel.input.didTapSortType)
            .store(in: &cancellables)
        
        reviewListView.writeButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapWrite)
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.sortType
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListViewControlelr, sortType: SubtabStackView.SortType) in
                owner.reviewListView.subtabStackView.selectTab(sortType)
            }
            .store(in: &cancellables)
        
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListViewControlelr, section: [ReviewListSection]) in
                owner.datasource.reload(section)
            }
            .store(in: &cancellables)
        
        viewModel.output.scrollToTop
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListViewControlelr, _) in
                owner.reviewListView.collectionView.scrollToTop(animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListViewControlelr, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: ReviewListViewControlelr, route: ReviewListViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: ReviewListViewModel.Route) {
        switch route {
        case .presentWriteReview(let viewModel):
            let viewController = ReviewBottomSheetViewController.instance(viewModel: viewModel)
            
            presentPanModal(viewController)
        case .presentReportBottomSheetReview(let viewModel):
            presentReportReviewBottomSheet(viewModel)
        case .presentDeleteReviewAlert(let index):
            AlertUtils.showWithCancel(
                viewController: self,
                message: Strings.ReviewList.Alert.delete
            ) { [weak self] in
                self?.viewModel.input.deleteReview.send(index)
            }
        }
    }
    
    private func presentReportReviewBottomSheet(_ viewModel: ReportReviewBottomSheetViewModel) {
        let viewController = ReportReviewBottomSheetViewController.instance(viewModel: viewModel)
        
        presentPanModal(viewController)
    }
}
