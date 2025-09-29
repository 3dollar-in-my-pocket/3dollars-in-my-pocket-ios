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
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private lazy var dimView = UIView(frame: self.view.frame).then {
        $0.backgroundColor = .clear
    }
    
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
        guard let membershipInterface = DIContainer.shared.container.resolve(MembershipInterface.self) else {
            fatalError("⚠️ MembershipInterface가 등록되지 않았습니다.")
        }
        
        guard let writeInterface = DIContainer.shared.container.resolve(WriteInterface.self) else {
            fatalError("⚠️ WriteInterface가 등록되지 않았습니다.")
        }
        
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else {
            fatalError("⚠️ StoreInterface가 등록되지 않았습니다.")
        }
        
        guard let myPageInterface = DIContainer.shared.container.resolve(MyPageInterface.self) else {
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
        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
        UITabBarItem.appearance().setTitleTextAttributes(
            [.font: Fonts.bold.font(size: 10) as Any],
            for: .normal
        )
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
            if #available(iOS 15, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = Colors.gray100.color
                self.tabBar.standardAppearance = appearance
                self.tabBar.scrollEdgeAppearance = appearance
            }
        case .home, .community:
            self.tabBar.barTintColor = .white
            if #available(iOS 15, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                self.tabBar.standardAppearance = appearance
                self.tabBar.scrollEdgeAppearance = appearance
            }
            
        case .write:
            break
        }
    }
    
    private func setupTabBarController() {
        self.setViewControllers(contentViewControllers, animated: true)
        self.tabBar.tintColor = Colors.mainRed.color
        self.tabBar.layer.borderWidth = 0
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        self.tabBar.barTintColor = .white
    }
    
    private func addKakaoLinkObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.processKakaoLinkIfExisted()
        }
    }
    
    private func removeKakaoLinkObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func processKakaoLinkIfExisted() {
        let kakaoShareLink = Preference.shared.shareLink
        guard !kakaoShareLink.isEmpty else { return }
        let storeType = kakaoShareLink.split(separator: ":").first ?? "foodTruck"
        let storeId = kakaoShareLink.split(separator: ":").last ?? ""
        
        selectedIndex = 0
        if storeType ==  "foodTruck" {
            pushBossStoreDetail(storeId: String(storeId))
        } else {
            selectedIndex = 0
            pushStoreDetail(storeId: String(storeId))
        }
        Preference.shared.shareLink = ""
    }
    
    private func pushBossStoreDetail(storeId: String) {
        guard let navigationController = contentViewControllers[safe: 0] as? UINavigationController else { return }
        let viewController = storeInterface.getBossStoreDetailViewController(storeId: storeId, shouldPushReviewList: false)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func pushStoreDetail(storeId: String) {
        guard let navigationController = contentViewControllers[safe: 0] as? UINavigationController,
              let storeId = Int(storeId) else { return }
        let viewController = storeInterface.getStoreDetailViewController(storeId: storeId)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func presentWriteAddress() {
        guard let focusedPosition = homeViewController.focusedPosition else { return }
        let config = WriteAddressViewModelConfig(
            address: homeViewController.currentAddress,
            location: focusedPosition
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
    final class WriteTabBarIconViewController: UIViewController {
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
