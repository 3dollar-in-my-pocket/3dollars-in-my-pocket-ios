import UIKit

import Common
import DesignSystem

final class BookmarkListViewController: BaseViewController {
    private let bookmarkView = BookmarkListView()
    private let viewModel: BookmarkListViewModel
    private lazy var datasource = BookmarkListDatasource(
        collectionView: bookmarkView.collectionView,
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
        view = bookmarkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarkView.collectionView.collectionViewLayout = datasource.createLayout()
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindEvent() {
        bookmarkView.backButton.controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isEnableShare
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkListViewController, isEnable: Bool) in
                owner.bookmarkView.setEnableShare(isEnable)
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
        // TODO: 라우팅 채워넣기
        switch route {
        case .presentShareBottomSheet:
            break
        case .pushStoreDetail(let storeId):
            let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .pushBossStoreDetail(let storeId):
            let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .pushEditBookmark:
            break
        case .presentDeleteAlert:
            let viewController = BookmarkListDeleteAlertViewController { [weak self] in
                self?.viewModel.input.deleteAllBookmark.send(())
            }
            
            present(viewController, animated: true)
        }
    }
}
