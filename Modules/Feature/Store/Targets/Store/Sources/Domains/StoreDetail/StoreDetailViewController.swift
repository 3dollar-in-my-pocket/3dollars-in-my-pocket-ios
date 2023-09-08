import UIKit

import Common

public final class StoreDetailViewController: BaseViewController {
    private let storeDetailView = StoreDetailView()
    private lazy var datasource = StoreDetailDatasource(collectionView: storeDetailView.collectionView)
    
    public static func instance() -> StoreDetailViewController {
        return StoreDetailViewController(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        view = storeDetailView
    }
    
    public override func viewDidLoad() {
        storeDetailView.collectionView.collectionViewLayout = createLayout()
        
        let sections: [StoreDetailSection] = [.init(type: .overview, items: [.overview])]
        
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
            }
        }
        
        return layout
    }
}
