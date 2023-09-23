import UIKit

import Model
import DesignSystem
import Then
import Common

public final class CommunityViewController: BaseViewController {

    private let communityView = CommunityView()
    private let viewModel = CommunityViewModel()
    private lazy var dataSource = CommunityDataSource(
        collectionView: communityView.collectionView,
        viewModel: viewModel
    )

    init() {
        super.init(nibName: nil, bundle: nil)

        tabBarItem = UITabBarItem(title: nil, image: Icons.communitySolid.image, tag: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func instance() -> UINavigationController {
        let viewController = CommunityViewController()
        viewController.tabBarItem = UITabBarItem(
            title: nil,
            image: Icons.communitySolid.image.resizeImage(scaledTo: 30),
            tag: TabBarTag.foodTruck.rawValue
        )

        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }

    public override func loadView() {
        super.loadView()

        view = communityView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.input.viewDidLoad.send(())
    }

    public override func bindEvent() {
        super.bindEvent()

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .pollCategoryTab:
                    let vc = PollCategoryTabViewController()
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .pollDetail:
                    let vc = PollDetailViewController()
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .popularStoreNeighborhoods:
                    let vc = CommunityPopularStoreNeighborhoodsViewController()
                    owner.present(vc, animated: true, completion: nil)
                }
            }
            .store(in: &cancellables)

        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
    }
}
