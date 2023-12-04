import UIKit

import Then

import Model
import DesignSystem
import Common
import StoreInterface

public final class CommunityViewController: BaseViewController {
    private let communityView = CommunityView()
    private let viewModel: CommunityViewModel
    private lazy var dataSource = CommunityDataSource(
        collectionView: communityView.collectionView,
        viewModel: viewModel,
        containerVC: self
    )

    init(viewModel: CommunityViewModel = CommunityViewModel()) {
        self.viewModel = viewModel

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
            tag: TabBarTag.community.rawValue
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

        viewModel.input.firstLoad.send(())
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppear.send(())
    }

    public override func bindEvent() {
        super.bindEvent()

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .pollCategoryTab(let viewModel):
                    let vc = PollCategoryTabViewController(viewModel: viewModel)
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .pollDetail(let viewModel):
                    let vc = PollDetailViewController(viewModel)
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .popularStoreNeighborhoods(let viewModel):
                    let vc = CommunityPopularStoreNeighborhoodsViewController(viewModel)
                    owner.present(vc, animated: true, completion: nil)
                case .storeDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                case .bossStoreDetail(let storeId):
                    owner.pushBossStoreDetail(storeId: storeId)
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

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: CommunityViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }

    private func pushStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushBossStoreDetail(storeId: String) {
        let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
