import UIKit
import Combine

import Common
import Model
import PanModal
import Log

final class CategoryFilterViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let categoryFilterView = CategoryFilterView()
    private let viewModel: CategoryFilterViewModel
    private lazy var dataSource = CategoryFilterDataSource(
        collectionView: categoryFilterView.collectionView,
        viewModel: viewModel,
        rootViewController: self
    )
    
    init(viewModel: CategoryFilterViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = categoryFilterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindViewModelOutput() {
        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { (owner: CategoryFilterViewController, dataSource: [CategorySection]) in
                owner.dataSource.reload(dataSource)
                DispatchQueue.main.async {
                    owner.viewModel.input.onCollectionViewLoaded.send(())
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.selectCategory
            .main
            .compactMap { $0 }
            .withUnretained(self)
            .sink { (owner: CategoryFilterViewController, selectedCategory: StoreFoodCategoryResponse) in
                owner.selectCategory(selectedCategory)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: CategoryFilterViewController, route: CategoryFilterViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func selectCategory(_ selectedCategory: StoreFoodCategoryResponse) {
        for (sectionIndex, section) in dataSource.snapshot().sectionIdentifiers.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if case .category(let category) = item,
                   category == selectedCategory {
                    let indexPath = IndexPath(row: itemIndex, section: sectionIndex)
                    categoryFilterView.collectionView.cellForItem(at: indexPath)?.isSelected = true
                    break
                }
            }
        }
    }
}

// MARK: Route
extension CategoryFilterViewController {
    private func handleRoute(_ route: CategoryFilterViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .dismiss:
            dismiss(animated: true)
        }
    }
}

// MARK: PanModalPresentable
extension CategoryFilterViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        categoryFilterView.collectionView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(520)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var panModalBackgroundColor: UIColor {
        return .clear
    }
    
    var cornerRadius: CGFloat {
        return 12
    }
    
    var allowsExtendedPanScrolling: Bool {
        return true
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
