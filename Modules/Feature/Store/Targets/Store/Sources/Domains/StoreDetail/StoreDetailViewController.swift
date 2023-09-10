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
        
        let sections: [StoreDetailSection] = [
            .init(type: .overview, items: [.overview]),
            .init(type: .visit, items: [.visit])
        ]
        
        datasource.reload(sections)
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
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreDetailVisitCell.Layout.height)
                ))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailVisitCell.Layout.height)
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
            }
        }
        
        return layout
    }
}
