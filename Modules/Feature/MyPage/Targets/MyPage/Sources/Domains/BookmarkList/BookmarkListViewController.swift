import UIKit

import Common
import DesignSystem

final class BookmarkListViewController: BaseViewController {
    private let bookmarkListView = BookmarkListView()
    private let viewModel: BookmarkListViewModel
    private lazy var datasource = BookmarkListDatasource(
        collectionView: bookmarkListView.collectionView,
        viewModel: viewModel
    )
    
    init(viewModel: BookmarkListViewModel = BookmarkListViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = bookmarkListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarkListView.collectionView.collectionViewLayout = datasource.createLayout()
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindEvent() {
        bookmarkListView.backButton.controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        bookmarkListView.shareButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapShare)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isEnableShare
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, isEnable: Bool) in
                owner.bookmarkListView.setEnableShare(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, sections: [BookmarkListSection]) in
                owner.datasource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, route: BookmarkListViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: BookmarkListViewModel.Route) {
        switch route {
        case .presentShareBottomSheet(let url):
            let viewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            
            viewController.popoverPresentationController?.sourceView = bookmarkListView
            present(viewController, animated: true)
        case .pushStoreDetail(let storeId):
            let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .pushBossStoreDetail(let storeId):
            let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .pushEditBookmark(let viewModel):
            let viewController = EditBookmarkViewController(viewModel: viewModel)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .presentDeleteAlert:
            let viewController = BookmarkListDeleteAlertViewController { [weak self] in
                self?.viewModel.input.deleteAllBookmark.send(())
            }
            
            present(viewController, animated: true)
        }
    }
}
