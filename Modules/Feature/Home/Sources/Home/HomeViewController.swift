import UIKit

import DesignSystem

public class HomeViewController: UIViewController {
    private let homeView = HomeView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        // TODO: 태그 정의 필요
        tabBarItem = UITabBarItem(title: nil, image: DesignSystemAsset.Icons.homeSolid.image, tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func instance() -> HomeViewController {
        return HomeViewController()
    }
    
    public override func loadView() {
        view = homeView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        homeView.collectionView.dataSource = self
    }
}

extension HomeViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomeCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        return cell
    }
}
