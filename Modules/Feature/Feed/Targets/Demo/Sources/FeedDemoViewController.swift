import UIKit

import Common
import Feed
import FeedInterface

import SnapKit

final class FeedDemoViewController: UIViewController {
    enum ViewType: CaseIterable {
        case feedList
        
        var title: String {
            switch self {
            case .feedList:
                return "피드 리스트"
            }
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            UICollectionViewCell.self,
            FeedDemoCollectionViewCell.self
        ])
        return collectionView
    }()
    
    private let dataSource: [ViewType] = ViewType.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        title = "Feed Demo"
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = FeedDemoCollectionViewCell.Layout.size
        return layout
    }
}

extension FeedDemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewType = dataSource[safe: indexPath.row] else {
            return collectionView.dequeueReusableCell(indexPath: indexPath)
        }
        let cell: FeedDemoCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(viewType: viewType)
        return cell
    }
}

extension FeedDemoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewType = dataSource[safe: indexPath.item] else { return }
        
        switch viewType {
        case .feedList:
            let config = FeedListViewModelConfig(
                mapLatitude: 37.287934,
                mapLongitude: 127.056573
            )
            let viewModel = FeedListViewModel(config: config)
            let viewController = FeedListViewController(viewModel: viewModel)
            present(viewController, animated: true)
        }
    }
}
