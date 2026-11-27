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

import Kingfisher

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

    private lazy var contentViewControllers: [UIViewController] = items.map(makeContentViewController)
    private lazy var homeNavigationController = UINavigationController(rootViewController: homeViewController)

    private let homeViewController = HomeViewController()
    private let items: [MainTabBarItem]

    private let membershipInterface: MembershipInterface
    private let writeInterface: WriteInterface
    private let storeInterface: StoreInterface
    private let myPageInterface: MyPageInterface
    private let viewModel: MainTabBarViewModel
    private var cancellables = Set<AnyCancellable>()

    deinit {
        self.removeKakaoLinkObserver()
    }

    init(
        viewModel: MainTabBarViewModel = MainTabBarViewModel(),
        bottomNavigationStore: BottomNavigationStoring = BottomNavigationStore.shared
    ) {
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
        self.items = MainTabBarItem.items(from: bottomNavigationStore.response)
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
        self.selectTab(index: MainTabBarItem.initialIndex(of: items))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.processKakaoLinkIfExisted()
        DeepLinkHandler.shared.handleReservedDeepLink()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.feedbackGenerator.selectionChanged()

        guard let tabItem = items[safe: item.tag] else { return }
        self.setTabBarColor(item: tabItem)
    }

    func applyHomeDeepLink(preset: String?, tabId: String?) {
        homeViewController.applyDeepLink(preset: preset, tabId: tabId)
    }

    func landStoreOnHome(storeId: Int, isExpanded: Bool) {
        homeViewController.landStoreFromDeepLink(storeId: storeId, isExpanded: isExpanded)
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
        guard let index = items.firstIndex(where: { $0.tag == tab }) else { return }
        selectTab(index: index)
    }

    func selectTab(id: String) {
        guard let index = items.firstIndex(where: { $0.id.lowercased() == id.lowercased() }),
              let item = items[safe: index] else { return }

        switch item.destination {
        case .native(.write):
            presentWriteAddress()
        case .deeplink(let link):
            guard !Self.isTabLink(link) else { return }
            DeepLinkHandler.shared.handleLinkResponse(link)
        case .native(.my) where Preference.shared.isAnonymousUser:
            presentSigninAnonymous()
        case .native, .web:
            selectTab(index: index)
        }
    }

    func popHomeToRoot() {
        homeNavigationController.popToRootViewController(animated: false)
    }

    private func selectTab(index: Int) {
        guard let item = items[safe: index] else { return }
        self.selectedIndex = index
        self.setTabBarColor(item: item)
    }

    private func presentSigninAnonymous() {
        let viewController = membershipInterface.createSigninAnonymousViewController(onSignin: nil)
        present(viewController, animated: true)
    }

    private static func isTabLink(_ link: SDLink) -> Bool {
        let path = URL(string: link.link)?.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return path == DeeplinkPath.tab.path
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

    private func setTabBarColor(item: MainTabBarItem) {
        switch item.destination {
        case .native(.my):
            guard !Preference.shared.isAnonymousUser else { return }
            self.tabBar.barTintColor = Colors.gray100.color
            self.applyTabBarAppearance(backgroundColor: Colors.gray100.color, selectedItem: item)
        case .native(.home), .native(.community), .web:
            self.tabBar.barTintColor = .white
            self.applyTabBarAppearance(backgroundColor: .white, selectedItem: item)
        case .native(.write), .deeplink:
            break
        }
    }

    private func applyTabBarAppearance(backgroundColor: UIColor, selectedItem: MainTabBarItem? = nil) {
        let selectedTintColor = (selectedItem ?? items.first)?.selectedTintColor ?? Colors.mainRed.color
        let appearance = Self.makeTabBarAppearance(backgroundColor: backgroundColor, selectedColor: selectedTintColor)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = selectedTintColor
        tabBar.unselectedItemTintColor = Colors.gray40.color

        // iOS 26+ 의 새 탭바는 컨트롤러 레벨 appearance 를 일부만 반영해서
        // 아이템별 appearance 로도 같은 값을 지정해야 비선택 색이 적용된다.
        zip(contentViewControllers, items).forEach { viewController, item in
            let itemAppearance = Self.makeTabBarAppearance(
                backgroundColor: backgroundColor,
                selectedColor: item.selectedTintColor
            )
            viewController.tabBarItem.standardAppearance = itemAppearance
            viewController.tabBarItem.scrollEdgeAppearance = itemAppearance
        }
    }

    private static func makeTabBarAppearance(backgroundColor: UIColor, selectedColor: UIColor) -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = Colors.gray20.color

        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach { itemAppearance in
            itemAppearance.normal.iconColor = Colors.gray40.color
            itemAppearance.normal.titleTextAttributes = titleAttributes(color: Colors.gray40.color)
            itemAppearance.selected.iconColor = selectedColor
            itemAppearance.selected.titleTextAttributes = titleAttributes(color: selectedColor)
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
        self.tabBar.tintColor = items.first?.selectedTintColor ?? Colors.mainRed.color
        self.tabBar.layer.borderWidth = 0
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        self.tabBar.barTintColor = .white
        self.applyTabBarItems()
    }

    private func applyTabBarItems() {
        for (index, item) in items.enumerated() {
            guard let viewController = contentViewControllers[safe: index] else { continue }
            let tabBarItem = UITabBarItem(
                title: item.title,
                image: item.icon.map(Self.tabBarIcon),
                tag: index
            )
            tabBarItem.imageInsets = .zero
            tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: Layout.titleOffset)
            viewController.tabBarItem = tabBarItem
            loadRemoteIcon(for: tabBarItem, urlString: item.iconUrl)
        }
    }

    private func loadRemoteIcon(for tabBarItem: UITabBarItem, urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else { return }

        KingfisherManager.shared.retrieveImage(with: url) { result in
            guard case .success(let value) = result else { return }
            DispatchQueue.main.async {
                tabBarItem.image = Self.tabBarIcon(value.image)
            }
        }
    }

    private static func tabBarIcon(_ image: UIImage) -> UIImage {
        image.resizeImage(scaledTo: MainTabBarItem.iconSize).withRenderingMode(.alwaysTemplate)
    }

    private func makeContentViewController(item: MainTabBarItem) -> UIViewController {
        switch item.destination {
        case .native(.home):
            return homeNavigationController
        case .native(.write), .deeplink:
            return WriteTabBarIconViewController()
        case .native(.community):
            return Community.CommunityViewController.instance()
        case .native(.my):
            return myPageInterface.getMyPageViewController()
        case .web(let url):
            return WebTabViewController(url: url)
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

        selectTab(tab: .home)
        pushStoreDetail(storeId: kakaoShareLink)
        Preference.shared.shareLink = ""
    }

    private func pushStoreDetail(storeId: String) {
        guard let storeId = Int(storeId) else { return }
        let viewController = storeInterface.getStoreDetailFullScreenViewController(storeId: storeId)

        homeNavigationController.pushViewController(viewController, animated: true)
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
        let item = contentViewControllers.firstIndex(of: viewController).flatMap { items[safe: $0] }
        if let item {
            viewModel.input.didTapTab.send(item)
        }

        if let navigationViewController = tabBarController.selectedViewController as? UINavigationController,
           navigationViewController.topViewController is HomeViewController,
           let presentedViewController = navigationViewController.presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        switch item?.destination {
        case .native(.write):
            presentWriteAddress()
            return false
        case .deeplink(let link):
            DeepLinkHandler.shared.handleLinkResponse(link)
            return false
        default:
            break
        }

        if let navigationViewController = viewController as? UINavigationController {
            if navigationViewController.topViewController is MyPage.MyPageViewController,
               Preference.shared.isAnonymousUser {
                presentSigninAnonymous()
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
