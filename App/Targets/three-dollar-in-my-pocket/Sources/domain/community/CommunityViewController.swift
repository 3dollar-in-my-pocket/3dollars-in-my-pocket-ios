import UIKit

import Model
import DesignSystem

final class CommunityViewController: BaseViewController {

    private let communityView = CommunityView()
    private let viewModel = CommunityViewModel()
    private lazy var dataSource = CommunityDataSource(collectionView: communityView.collectionView)

    init() {
        super.init(nibName: nil, bundle: nil)

        tabBarItem = UITabBarItem(title: nil, image: DesignSystemAsset.Icons.communitySolid.image, tag: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func instance() -> UINavigationController {
        let viewController = CommunityViewController()

        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }

    override func loadView() {
        super.loadView()

        view = communityView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        communityView.collectionView.delegate = self

        dataSource.reloadData()
    }

    override func bindEvent() {
        super.bindEvent()
    }
}

extension CommunityViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .poll:
            return CommunityPollListCell.Layout.size
        default:
            return .zero
        }
    }
}
