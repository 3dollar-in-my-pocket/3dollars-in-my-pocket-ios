import UIKit
import Combine

import Common
import Model

extension HomeFilterCollectionView {
    enum Layout {
        static let interItemSpacing: CGFloat = 10
        
        static func createLayout() -> UICollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = Layout.interItemSpacing
            layout.scrollDirection = .horizontal
            return layout
        }
    }
    
    enum CellType {
        case category(StoreFoodCategoryResponse?)
        case recentActivity(Bool)
        case sortingFilter(StoreSortType)
        case onlyBoss(Bool)
        
        var icon: UIImage? {
            switch self {
            case .category:
                return nil
            case .sortingFilter:
                return Icons.change.image
                    .resizeImage(scaledTo: 16)
                    .withImageInset(insets: .init(top: 2, left: 2, bottom: 2, right: 2))
            case .recentActivity:
                return "🔥".image()?.withImageInset(insets: .init(top: 3, left: 3, bottom: 3, right: 3))
            case .onlyBoss:
                return "🧑‍🍳".image()?.withImageInset(insets: .init(top: 3, left: 3, bottom: 3, right: 3))
            }
        }
        
        var title: String? {
            switch self {
            case .category:
                return nil
            case .recentActivity:
                return HomeStrings.homeRecentActivity
            case .sortingFilter(let sortType):
                switch sortType {
                case .distanceAsc:
                    return HomeStrings.homeSortingButtonDistance
                case .latest:
                    return HomeStrings.homeSortingButtonLatest
                case .unknown:
                    return nil
                }
            case .onlyBoss:
                return HomeStrings.homeOnlyBossButton
            }
        }
    }
}

final class HomeFilterCollectionView: UICollectionView {
    var onLoadFilter: (() -> Void)?
    private var datasource: [CellType] = []
    private let homeFilterSelectable: HomeFilterSelectable
    private var cancellables = Set<AnyCancellable>()
    private var isFirstLoad = true
    
    init(homeFilterSelectable: HomeFilterSelectable) {
        self.homeFilterSelectable = homeFilterSelectable
        super.init(frame: .zero, collectionViewLayout: Layout.createLayout())
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
        register([
            HomeFilterCell.self,
            BaseCollectionViewCell.self
        ])
        
        showsHorizontalScrollIndicator = false
        contentInset = .init(top: 13, left: 22, bottom: 13, right: 22)
        
        delegate = self
        dataSource = self
        
        homeFilterSelectable.filterDatasource
            .main
            .withUnretained(self)
            .sink { (owner: HomeFilterCollectionView, datasource: [CellType]) in
                owner.datasource = datasource
                owner.reloadData()
                
                if owner.isFirstLoad {
                    owner.isFirstLoad = false
                    DispatchQueue.main.async {
                        owner.onLoadFilter?()
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension HomeFilterCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = datasource[safe: indexPath.item] else { return BaseCollectionViewCell() }
        
        switch item {
        case .category(let category):
            let cell: HomeFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(category: category)
            return cell
        case .recentActivity(let isOn):
            let cell: HomeFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(icon: item.icon, title: item.title, isSelected: isOn)
            return cell
        case .sortingFilter:
            let cell: HomeFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(icon: item.icon, title: item.title)
            return cell
        case .onlyBoss(let isOn):
            let cell: HomeFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(icon: item.icon, title: item.title, isSelected: isOn)
            return cell
        }
    }
}

extension HomeFilterCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = datasource[safe: indexPath.item] else { return .zero }
        
        switch item {
        case .category(let category):
            return HomeFilterCell.Layout.size(title: category?.name ?? HomeStrings.homeCategoryFilterButton)
        case .recentActivity, .onlyBoss, .sortingFilter:
            return HomeFilterCell.Layout.size(title: item.title)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = datasource[safe: indexPath.item] else { return }
        
        switch item {
        case .category:
            homeFilterSelectable.onTapCategoryFilter.send(())
        case .recentActivity:
            homeFilterSelectable.onTapOnlyRecentActivity.send(())
        case .sortingFilter(let sortType):
            homeFilterSelectable.onToggleSort.send(sortType)
        case .onlyBoss:
            homeFilterSelectable.onTapOnlyBoss.send(())
        }
    }
}

private extension String {
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),withAttributes: attributes)
        }
    }
}
