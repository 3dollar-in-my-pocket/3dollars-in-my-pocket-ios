import UIKit

import Common
import Model
import DesignSystem

typealias CategorySelectionSnapshot = NSDiffableDataSourceSnapshot<CategorySelectionSection, CategorySelectionItem>

final class CategorySelectionViewController: BaseViewController {
    private let categorySelectionView = CategorySelectionView()
    private let viewModel: CategorySelectionViewModel
    private lazy var dataSource = CategorySelectionDataSource(collectionView: categorySelectionView.categoryCollectionView, viewModel: viewModel)
    
    init(viewModel: CategorySelectionViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = categorySelectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
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
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                owner.handleRoute(route: route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(route: CategorySelectionViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss()
        }
    }
    
    private func dismiss(completion: (() -> Void)? = nil) {
        DimManager.shared.hideDim()
        dismiss(animated: true, completion: completion)
    }
}
