import UIKit

final class BookmarkViewerViewController: BaseViewController {
    private let bookmarkViewerView = BookmarkViewerView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        self.view = self.bookmarkViewerView
    }
    
    static func instance(folderId: String) -> UINavigationController {
        let viewController = BookmarkViewerViewController(nibName: nil, bundle: nil)
        
        return UINavigationController(rootViewController: viewController).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.isNavigationBarHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bookmarkViewerView.collectionView.dataSource = self
        self.bookmarkViewerView.collectionView.delegate = self
    }
}

// 뷰 테스트를 위해 임시로 작성한 코드입니다. 리액터 만들어지고 데이터 바인딩 되면 제거될 코드입니다.
extension BookmarkViewerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: BookmarkViewerStoreCollectionViewCell = collectionView.dequeueReuseableCell(
            indexPath: indexPath
        )
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView: BookmarkViewerHeaderView = collectionView.dequeueReusableSupplementaryView(
            ofkind: UICollectionView.elementKindSectionHeader,
            indexPath: indexPath
        )
        
        return headerView
    }
}
