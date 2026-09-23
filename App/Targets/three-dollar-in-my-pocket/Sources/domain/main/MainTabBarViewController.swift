import UIKit
import Combine
import CoreLocation

import Common
import Model
import DependencyInjection

import Home
import MyPage
import Community

import DesignSystem
import MembershipInterface
import WriteInterface
import StoreInterface
import MyPageInterface

final class MainTabBarViewController: UITabBarController {
    private enum Layout {
        static let iconSize: CGFloat = 24
        static let titleFontSize: CGFloat = 12
        static let titleLineHeight: CGFloat = 18
        static let titleKern: CGFloat = -0.12
        static let titleOffset: CGFloat = -2
    }

    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private lazy var dimView: UIView = {
        let dimView = UIView(frame: self.view.frame)
        dimView.backgroundColor = .clear
        return dimView
    }()

    private lazy var contentViewControllers: [UIViewController] = [
        UINavigationController(rootViewController: homeViewController),
        WriteTabBarIconViewController(),
        Community.CommunityViewController.instance(),
        myPageInterface.getMyPageViewController()
    ]

    private let homeViewController = HomeViewController()

    private let membershipInterface: MembershipInterface
    private let writeInterface: WriteInterface
    private let storeInterface: StoreInterface
    private let myPageInterface: MyPageInterface
    private let viewModel: MainTabBarViewModel
    private var cancellables = Set<AnyCancellable>()

    deinit {
        self.removeKakaoLinkObserver()
    }

    init(viewModel: MainTabBarViewModel = MainTabBarViewModel()) {
        guard let membershipInterface = DIContainer.shared.resolver.resolve(MembershipInterface.self) else {
            fatalError("⚠️ MembershipInterface가 등록되지 않았습니다.")
        }

        guard let writeInterface = DIContainer.shared.resolver.resolve(WriteInterface.self) else {
            fatalError("⚠️ WriteInterface가 등록되지 않았습니다.")
        }

        guard let storeInterface = DIContainer.shared.resolver.resolve(StoreInterface.self) else {
            fatalError("⚠️ StoreInterface가 등록되지 않았습니다.")
        }

        guard let myPageInterface = DIContainer.shared.resolver.resolve(MyPageInterface.self) else {
            fatalError("⚠️ MyPageInterface가 등록되지 않았습니다.")
        }

        self.membershipInterface = membershipInterface
        self.writeInterface = writeInterface
        self.storeInterface = storeInterface
        self.myPageInterface = myPageInterface
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()

        viewModel.input.viewDidLoad.send(())

        self.setupTabBarController()
        self.addKakaoLinkObserver()
        self.feedbackGenerator.prepare()
        self.delegate = self
        self.applyTabBarAppearance(backgroundColor: .white)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.processKakaoLinkIfExisted()
        DeepLinkHandler.shared.handleReservedDeepLink()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.feedbackGenerator.selectionChanged()

        guard let tab = TabBarTag(rawValue: item.tag) else { return }
        self.setTabBarColor(tab: tab)
    }

    func applyHomePreset(_ preset: String) {
        homeViewController.applyPreset(preset)
    }

    func showLoading(isShow: Bool) {
        LoadingManager.shared.showLoading(isShow: isShow)
    }

    func showDim(isShow: Bool) {
        if isShow {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.addSubview(self.dimView)
                UIView.animate(withDuration: 0.3) {
                    self.dimView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.5)
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3, animations: {
                    self.dimView.backgroundColor = .clear
                }) { (_) in
                    self.dimView.removeFromSuperview()
                }
            }
        }
    }

    func selectTab(tab: TabBarTag) {
        self.selectedIndex = tab.rawValue
        self.setTabBarColor(tab: tab)
    }

    private func bind() {
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: MainTabBarViewController, route: MainTabBarViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }

    private func handleRoute(_ route: MainTabBarViewModel.Route) {
        switch route {
        case .presentMainBannerPopup(let viewModel):
            presentMainBannerPopup(viewModel)
        }
    }

    private func presentMainBannerPopup(_ viewModel: MainBannerPopupViewModel) {
        let viewController = MainBannerPopupViewController(viewModel: viewModel)

        present(viewController, animated: true)
    }

    private func setTabBarColor(tab: TabBarTag) {
        switch tab {
        case .my:
            guard !Preference.shared.isAnonymousUser else { return }
            self.tabBar.barTintColor = Colors.gray100.color
            self.applyTabBarAppearance(backgroundColor: Colors.gray100.color)
        case .home, .community:
            self.tabBar.barTintColor = .white
            self.applyTabBarAppearance(backgroundColor: .white)
        case .write:
            break
        }
    }

    private func applyTabBarAppearance(backgroundColor: UIColor) {
        let appearance = Self.makeTabBarAppearance(backgroundColor: backgroundColor)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = Colors.mainRed.color
        tabBar.unselectedItemTintColor = Colors.gray40.color

        // iOS 26+ 의 새 탭바는 컨트롤러 레벨 appearance 를 일부만 반영해서
        // 아이템별 appearance 로도 같은 값을 지정해야 비선택 색이 적용된다.
        contentViewControllers.forEach { viewController in
            viewController.tabBarItem.standardAppearance = appearance
            viewController.tabBarItem.scrollEdgeAppearance = appearance
        }
    }

    private static func makeTabBarAppearance(backgroundColor: UIColor) -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = Colors.gray20.color

        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach { itemAppearance in
            itemAppearance.normal.iconColor = Colors.gray40.color
            itemAppearance.normal.titleTextAttributes = titleAttributes(color: Colors.gray40.color)
            itemAppearance.selected.iconColor = Colors.mainRed.color
            itemAppearance.selected.titleTextAttributes = titleAttributes(color: Colors.mainRed.color)
        }
        return appearance
    }

    private static func titleAttributes(color: UIColor) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = Layout.titleLineHeight
        paragraphStyle.maximumLineHeight = Layout.titleLineHeight

        return [
            .font: Fonts.medium.font(size: Layout.titleFontSize) as Any,
            .foregroundColor: color,
            .kern: Layout.titleKern,
            .paragraphStyle: paragraphStyle
        ]
    }

    private func setupTabBarController() {
        self.setViewControllers(contentViewControllers, animated: true)
        self.tabBar.tintColor = Colors.mainRed.color
        self.tabBar.layer.borderWidth = 0
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        self.tabBar.barTintColor = .white
        self.applyTabBarItems()
    }

    private func applyTabBarItems() {
        for (index, item) in MainTabBarItem.all.enumerated() {
            guard let viewController = contentViewControllers[safe: index] else { continue }
            let tabBarItem = UITabBarItem(
                title: item.title,
                image: item.icon.resizeImage(scaledTo: MainTabBarItem.iconSize).withRenderingMode(.alwaysTemplate),
                tag: item.tag.rawValue
            )
            tabBarItem.imageInsets = .zero
            tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: Layout.titleOffset)
            viewController.tabBarItem = tabBarItem
        }
    }

    private func addKakaoLinkObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.processKakaoLinkIfExisted()
        }
    }

    private func removeKakaoLinkObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    private func processKakaoLinkIfExisted() {
        let kakaoShareLink = Preference.shared.shareLink
        guard !kakaoShareLink.isEmpty else { return }

        selectedIndex = 0
        pushStoreDetail(storeId: kakaoShareLink)
        Preference.shared.shareLink = ""
    }

    private func pushStoreDetail(storeId: String) {
        guard let navigationController = contentViewControllers[safe: 0] as? UINavigationController,
              let storeId = Int(storeId) else { return }
        let viewController = storeInterface.getStoreDetailFullScreenViewController(storeId: storeId)

        navigationController.pushViewController(viewController, animated: true)
    }

    private func presentWriteAddress() {
        guard let focusedPosition = homeViewController.focusedPosition else { return }
        let config = WriteAddressViewModelConfig(
            address: homeViewController.currentAddress,
            location: focusedPosition,
            shouldSkipCheckingAround: false
        )

        let writeViewController = writeInterface.getWriteAddressViewController(config: config) { [weak self] storeId in
            self?.pushStoreDetail(storeId: storeId)
        }

        present(writeViewController, animated: true, completion: nil)
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        if let tab = TabBarTag(rawValue: viewController.tabBarItem.tag) {
            viewModel.input.didTapTab.send(tab)
        }

        if let navigationViewController = tabBarController.selectedViewController as? UINavigationController,
           navigationViewController.topViewController is HomeViewController,
           let presentedViewController = navigationViewController.presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        if viewController == contentViewControllers[safe: 1] {
            presentWriteAddress()
            return false
        }

        if let navigationViewController = viewController as? UINavigationController {
            if navigationViewController.topViewController is MyPage.MyPageViewController,
               Preference.shared.isAnonymousUser {
                let viewController = membershipInterface.createSigninAnonymousViewController()

                self.present(viewController, animated: true)
                return false
            }
        }
        return true
    }
}

extension MainTabBarViewController {
    final class WriteTabBarIconViewController: BaseViewController {
        init() {
            super.init(nibName: nil, bundle: nil)

            tabBarItem = UITabBarItem(
                title: nil,
                image: DesignSystemAsset.Icons.writeSolid.image,
                tag: TabBarTag.write.rawValue
            )
        }

        required init?(coder: NSCoder) {
            fatalError()
        }
    }
}
