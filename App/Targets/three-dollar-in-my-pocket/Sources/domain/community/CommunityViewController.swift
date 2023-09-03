import UIKit

import Model
import DesignSystem

final class CommunityViewController: BaseViewController {

    private let communityView = CommunityView()

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
    }

    override func bindEvent() {
        super.bindEvent()
    }
}
