import UIKit

typealias CategorySelectionSnapshot = NSDiffableDataSourceSnapshot<CategorySelectionSection, CategorySelectionItem>

protocol CategorySelectionDelegate: AnyObject {
    func onSelectCategories(categories: [PlatformStoreCategory])
}

final class CategorySelectionViewController: BaseBottomSheetViewController, CategorySelectionCoordinator {
    weak var delegate: CategorySelectionDelegate?
    private let categorySelectionView = CategorySelectionView()
    private let viewModel: CategorySelectionViewModel
    private weak var coordinator: CategorySelectionCoordinator?
    private lazy var dataSource = CategorySelectionDataSource(collectionView: categorySelectionView.categoryCollectionView, viewModel: viewModel)
    
    static func instance(selectedCategories: [PlatformStoreCategory]) -> CategorySelectionViewController {
        return CategorySelectionViewController(selectedCategories: selectedCategories)
    }
    
    init(selectedCategories: [PlatformStoreCategory]) {
        self.viewModel = CategorySelectionViewModel(state: CategorySelectionViewModel.State(selectedCategories: selectedCategories))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = categorySelectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinator = self
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindEvent() {
        categorySelectionView.backgroundButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss()
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        categorySelectionView.selectButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.tapSelect)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.categories
            .map { categories in
                CategorySelectionSection(
                    type: .category,
                    items: categories.map { .category($0) }
                )
            }
            .withUnretained(self)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { owner, section in
                owner.categorySelectionView.updateCollectionViewHeight(itemCount: section.items.count)
            })
            .sink { owner, section in
                var snapshot = CategorySelectionSnapshot()
                snapshot.appendSections([section])
                snapshot.appendItems(section.items)
                
                owner.dataSource.apply(snapshot, animatingDifferences: true)
                owner.viewModel.input.onLoadDataSource.send(())
            }
            .store(in: &cancellables)
        
        viewModel.output.selectCategories
            .withUnretained(self)
            .sink { owner, selectedCategories in
                for category in selectedCategories {
                    if let index = owner.dataSource.snapshot().indexOfItem(.category(category)) {
                        let indexPath = IndexPath(row: index, section: 0)
                        owner.categorySelectionView.categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableSelectButton
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: categorySelectionView.selectButton)
            .store(in: &cancellables)
        
        viewModel.output.error
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, error in
                owner.coordinator?.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                owner.coordinator?.handleRoute(route: route)
            }
            .store(in: &cancellables)
    }
}
