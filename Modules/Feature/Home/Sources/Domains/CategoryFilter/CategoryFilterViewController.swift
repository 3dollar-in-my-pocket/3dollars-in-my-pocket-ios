import UIKit
import Combine

import Common
import PanModal

protocol CategoryFilterDelegate: AnyObject {
    func onSelectCategory(category: PlatformStoreCategory?)
}

final class CategoryFilterViewController: BaseViewController {
    weak var delegate: CategoryFilterDelegate?
    private let categoryFilterView = CategoryFilterView()
    private let viewModel: CategoryFilterViewModel
    private lazy var dataSource = CategoryFilterDataSource(
        collectionView: categoryFilterView.collectionView,
        viewModel: viewModel
    )
    
    static func instance(selectedCategory: PlatformStoreCategory? = nil) -> CategoryFilterViewController {
        return CategoryFilterViewController(selectedCategory: selectedCategory)
    }
    
    init(selectedCategory: PlatformStoreCategory? = nil) {
        self.viewModel = CategoryFilterViewModel(category: selectedCategory)
        
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
        Publishers.Zip(viewModel.output.categories, viewModel.output.advertisement)
            .withUnretained(self)
            .receive(on: DispatchQueue.main)
            .sink { owner, dataSourceItems in
                var categorySections: [CategorySection] = []
                let (categories, advertisement) = dataSourceItems
                let advertisementSectionItems = advertisement == nil ? [] : [CategorySectionItem.advertisement(advertisement)]
                let advertisementSection = CategorySection(title: "이 안에 네 최애 하나쯤은 있겠지!", items: advertisementSectionItems)
                
                categorySections.append(advertisementSection)
                
                let groupingByCategoryType = Dictionary(grouping: categories) { $0.classification }
                
                for categoryType in groupingByCategoryType.keys {
                    if let categories = groupingByCategoryType[categoryType] {
                        let categorySection = CategorySection(title: categoryType.description, items: categories.map { CategorySectionItem.category($0) })
                        
                        categorySections.append(categorySection)
                    }
                }
                
                owner.updateDataSource(section: categorySections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .showErrorAlert(let error):
                    print("🔥 Common 모듈에 AlertUtils 구현 필요")
                    
                case .dismissWithCategory(let category):
                    owner.delegate?.onSelectCategory(category: category)
                    owner.dismiss(animated: true)
                    
                case .goToWeb(let urlString):
                    owner.openURLWithSafari(urlString: urlString)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateDataSource(section: [CategorySection]) {
        var snapshot = CategoryFilterSanpshot()
        
        section.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func openURLWithSafari(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
}

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
