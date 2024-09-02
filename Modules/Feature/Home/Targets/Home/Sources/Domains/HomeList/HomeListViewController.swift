import UIKit

import Common
import Model
import DesignSystem
import DependencyInjection
import StoreInterface
import Log

import CombineCocoa

protocol HomeListDelegate: AnyObject {
    func didTapUserStore(storeId: Int)
    
    func didTapBossStore(storeId: String)
}

final class HomeListViewController: BaseViewController {
    override var screenName: ScreenName {
        return .homeList
    }
    
    weak var delegate: HomeListDelegate?
    private lazy var homeListView = HomeListView(homeFilterSelectable: viewModel)
    private let viewModel: HomeListViewModel
    private lazy var dataSource = HomeListDataSource(collectionView: homeListView.collectionView, viewModel: viewModel)
    
    init(viewModel: HomeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = homeListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        viewModel.input.viewDidLoad.send(())
        
        homeListView.bindAdvertisement(in: self)
    }
    
    private func bind() {
        homeListView.mapViewButton
            .tapPublisher
            .throttleClick()
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        // Output
        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
                
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: HomeListViewModel.Route) {
        switch route {
        case .presentCategoryFilter(let viewModel):
            let categoryFilterViewController = CategoryFilterViewController(viewModel: viewModel)
            presentPanModal(categoryFilterViewController)
        case .pushStoreDetail(let storeId):
            delegate?.didTapUserStore(storeId: Int(storeId) ?? 0)
        case .pushBossStoreDetail(let storeId):
            delegate?.didTapBossStore(storeId: storeId)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .openUrl(let url):
            openUrl(with: url)
        }
    }
    
    private func openUrl(with urlString: String?) {
        guard let urlString, 
                let url = URL(string: urlString), 
                UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
