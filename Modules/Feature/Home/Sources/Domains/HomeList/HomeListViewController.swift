import UIKit

import Common

final class HomeListViewController: BaseViewController {
    private let homeListView = HomeListView()
    private let viewModel: HomeListViewModel
    private lazy var dataSource = HomeListDataSource(collectionView: homeListView.collectionView, viewModel: viewModel)
    
    static func instance(state: HomeListViewModel.State) -> UINavigationController {
        let viewController = HomeListViewController(state: state)
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init(state: HomeListViewModel.State) {
        self.viewModel = HomeListViewModel(state: state)
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
        
        viewModel.output.stores
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, storeCards in
                let items = storeCards.map { HomeListSectionItem.storeCard($0) }
                let section = HomeListSection(items: items)
                
                owner.updateDataSource(section: [section])
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
                owner.homeListView.onlyBossToggleButton.setSelected(isOnlyBoss)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .presentCategoryFilter(let category):
                    let categoryFilterViewController = CategoryFilterViewController.instance(selectedCategory: category)
                    categoryFilterViewController.delegate = owner
                    owner.presentPanModal(categoryFilterViewController)
                    
                case .pushStoreDetail(let storeId):
                    print("🔥 상품 상세화면 구현 필요")
                    
                case .showErrorAlert(let error):
                    print("🔥 Common 모듈에 AlertUtils 구현 필요")
                }
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
}

extension HomeListViewController: CategoryFilterDelegate {
    func onSelectCategory(category: PlatformStoreCategory?) {
        viewModel.input.selectCategory.send(category)
    }
}
