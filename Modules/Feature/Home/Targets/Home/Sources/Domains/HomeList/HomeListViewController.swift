import UIKit

import Common
import Model
import DesignSystem
import DependencyInjection
import StoreInterface
import Log

protocol HomeListDelegate: AnyObject {
    func didTapUserStore(storeId: Int)
    
    func didTapBossStore(storeId: String)
}

final class HomeListViewController: BaseViewController {
    override var screenName: ScreenName {
        return .homeList
    }
    
    weak var delegate: HomeListDelegate?
    private let homeListView = HomeListView()
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
        
        viewModel.input.viewDidLoad.send(())
        
        homeListView.mapViewButton
            .controlPublisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        homeListView.categoryFilterButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapCategoryFilter)
            .store(in: &cancellables)
        
        homeListView.sortingButton
            .sortTypePublisher
            .subscribe(viewModel.input.onToggleSort)
            .store(in: &cancellables)
        
        homeListView.onlyBossToggleButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapOnlyBoss)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.categoryFilter
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, category in
                owner.homeListView.categoryFilterButton.setCategory(category)
            }
            .store(in: &cancellables)
        
        viewModel.output.dataSource
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, sections in
                owner.updateDataSource(section: sections)
            }
            .store(in: &cancellables)
            
        viewModel.output.isEmptyAdvertisement
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isEmptyAdvertisement in
                owner.homeListView.bindAdvertisement(isHidden: !isEmptyAdvertisement, in: owner)
            }        
            .store(in: &cancellables)
        
        viewModel.output.sortType
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, sortType in
                owner.homeListView.sortingButton.bind(sortType)
            }
            .store(in: &cancellables)
        
        viewModel.output.isOnlyBoss
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isOnlyBoss in
                owner.homeListView.onlyBossToggleButton.isSelected = isOnlyBoss
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func updateDataSource(section: [HomeListSection]) {
        var snapshot = HomeListSnapshot()
        
        section.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func handleRoute(_ route: HomeListViewModel.Route) {
        switch route {
        case .presentCategoryFilter(let category):
            let categoryFilterViewController = CategoryFilterViewController.instance(selectedCategory: category)
            categoryFilterViewController.delegate = self
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

extension HomeListViewController: CategoryFilterDelegate {
    func onSelectCategory(category: PlatformStoreCategory?) {
        viewModel.input.selectCategory.send(category)
    }
}
