import UIKit

import Common
import Model
import DesignSystem

import PanModal

final class CategorySelectionViewController: BaseViewController {
    private let categorySelectionView = CategorySelectionView()
    private let viewModel: CategorySelectionViewModel
    private lazy var dataSource = CategorySelectionDataSource(collectionView: categorySelectionView.categoryCollectionView, viewModel: viewModel)
    
    init(viewModel: CategorySelectionViewModel) {
        self.viewModel = viewModel
        
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
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        viewModel.input.viewDidLoad.send(())
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
            .withUnretained(self)
            .receive(on: DispatchQueue.main)
            .sink { (owner: CategorySelectionViewController, categories: [PlatformStoreCategory]) in
                var categorySections: [CategorySelectionSection] = []
                
                let groupingByCategoryType = Dictionary(grouping: categories) { $0.classification }
                
                for categoryType in groupingByCategoryType.keys.sorted(by: <) {
                    if let categories = groupingByCategoryType[categoryType] {
                        let categorySection = CategorySelectionSection(type: .category, items: categories.map { CategorySelectionItem.category($0) })
                        
                        categorySections.append(categorySection)
                    }
                }
                
                owner.dataSource.reload(categorySections)
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
            dismiss(animated: true)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        DimManager.shared.hideDim()
        super.dismiss(animated: flag, completion: completion)
    }
}

extension CategorySelectionViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        categorySelectionView.categoryCollectionView
    }
    
    var shortFormHeight: PanModalHeight {
        return .maxHeight
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
