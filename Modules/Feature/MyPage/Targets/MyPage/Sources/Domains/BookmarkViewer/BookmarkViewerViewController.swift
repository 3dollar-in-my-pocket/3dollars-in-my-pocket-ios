import UIKit

import Common
import DesignSystem
import Log

public final class BookmarkViewerViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let bookmarkViewerView = BookmarkViewerView()
    private let viewModel: BookmarkViewerViewModel
    private lazy var datasource = BookmarkViewerDatasource(
        collectionView: bookmarkViewerView.collectionView,
        viewModel: viewModel
    )
    
    init(viewModel: BookmarkViewerViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        bookmarkViewerView.collectionView.collectionViewLayout = datasource.createLayout()
    }
    
    public convenience init(folderId: String) {
        let config = BookmarkViewerViewModel.Config(folderId: folderId)
        let viewModel = BookmarkViewerViewModel(config: config)
        
        self.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = bookmarkViewerView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.loadTrigger.send(())
    }
    
    public override func bindEvent() {
        bookmarkViewerView.closeButton.controlPublisher(for: .touchUpInside)
            .main
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    
    public override func bindViewModelOutput() {
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkViewerViewController, sections: [BookmarkViewerSection]) in
                owner.datasource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkViewerViewController, route: BookmarkViewerViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkViewerViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { isShow in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: BookmarkViewerViewModel.Route) {
        switch route {
        case .pushUserStoreDetail(let id):
            guard let storeId = Int(id) else { return }
            let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .pushBossStoreDetail(let id):
            let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: id)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .presentSigninDialog:
            let viewController = Environment.membershipInterface.createSigninBottomSheetViewController()
            
            present(viewController, animated: true)
        }
    }
}
