import UIKit

import Common

public final class StoreDetailViewController: BaseViewController {
    private let storeDetailView = StoreDetailView()
    private let viewModel: StoreDetailViewModel
    private lazy var datasource = StoreDetailDatasource(collectionView: storeDetailView.collectionView)
    
    public static func instance(storeId: Int) -> StoreDetailViewController {
        return StoreDetailViewController(storeId: storeId)
    }
    
    public init(storeId: Int) {
        self.viewModel = StoreDetailViewModel(storeId: storeId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = storeDetailView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.viewDidLoad.send(())
        
        storeDetailView.collectionView.collectionViewLayout = createLayout()
    }
    
    public override func bindViewModelInput() {
        
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.sections
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, sections: [StoreDetailSection]) in
                owner.datasource.reload(sections)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self,
                  let sectionIdentifier = datasource.sectionIdentifier(section: sectionIndex) else {
                return .init(group: .init(layoutSize: .init(
                    widthDimension: .absolute(0),
                    heightDimension: .absolute(0)
                )))
            }
            
            switch sectionIdentifier.type {
            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreDetailOverviewCell.Layout.height)
                ))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailOverviewCell.Layout.height)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                return section
                
            case .visit:
                let height = StoreDetailVisitCell.Layout.calculateHeight(histories: sectionIdentifier.items.first?.histories ?? [])
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                ))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(height)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(36)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
                
            case .info:
                let infoItemHeight = StoreDetailInfoCell.Layout.height
                let infoItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(infoItemHeight)
                ))
                
                let menuCellViewModel = sectionIdentifier.items.last?.menuCellViewModel
                let menuItemHeight = StoreDetailMenuCell.Layout.calculateHeight(
                    menus: menuCellViewModel?.output.menus ?? [],
                    isShowAll: menuCellViewModel?.output.isShowAll ?? false
                )
                let menuItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(menuItemHeight)
                ))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(infoItemHeight + menuItemHeight)
                    ),
                    subitems: [infoItem, menuItem]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
            }
        }
        
        return layout
    }
}
