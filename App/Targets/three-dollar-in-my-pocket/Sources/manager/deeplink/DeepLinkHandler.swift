import UIKit
import OSLog

import Common
import AppInterface
import Model
import Store
import MembershipInterface

import PanModal

final class DeepLinkHandler: DeepLinkHandlerProtocol {
    static let shared = DeepLinkHandler()
    
    private var canHandleDeepLink: Bool {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        
        if let navigationViewController = rootViewController as? UINavigationController {
            return navigationViewController.topViewController is MainTabBarViewController
        } else {
            return false
        }
    }
    
    private var reservedDeepLink: String?
    
    func handleAdvertisementLink(_ advertisementLink: AdvertisementLinkResponse) {
        switch advertisementLink.type {
        case .appScheme:
            let urlString = "\(Bundle.deeplinkScheme):/\(advertisementLink.url)"
            handle(urlString)
        case .web:
            let urlString = "\(Bundle.deeplinkScheme)://browser?url=\(advertisementLink.url)"
            handle(urlString)
        case .unknown:
            return
        }
    }
    
    func handle(_ urlString: String) {
        guard canHandleDeepLink else {
            reservedDeepLink = urlString
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        var path: String? = nil
        
        if isDynamicLinkHost(url: url) {
            path = url.relativePath.replacingOccurrences(of: "/", with: "")
        }
        
        if isAppScheme(url: url) {
            path = (url.host ?? "") + url.path
        }
        
        guard let path else { return }
        let deepLinkPath = DeeplinkPath(value: path)
        
        switch deepLinkPath {
        case .bookmark:
            guard let params = url.params(),
                  let folderId = params["folderId"] as? String else { return }
            let viewController = Environment.myPageInterface.getBookmarkViewerViewController(folderId: folderId)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationStyle = .overCurrentContext
            route(navigationController)
        case .store:
            guard let params = url.params(),
                  let storeTypeString = params["storeType"] as? String,
                  let storeId = params["storeId"] as? String else { return }
            
            var viewController: UIViewController
            switch StoreType(value: storeTypeString) {
            case .userStore:
                viewController = Environment.storeInterface.getStoreDetailViewController(storeId: Int(storeId) ?? 0)
            case .bossStore:
                viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId)
            case .unknown:
                return
            }
            route(viewController)
        case .home:
            moveTab(.home)
        case .medal:
            let targetViewController = Environment.myPageInterface.getMyMedalViewController()
            route(targetViewController)
        case .community:
            moveTab(.community)
        case .pollDetail:
            guard let params = url.params(),
                  let pollId = params["pollId"] as? String else { return }
            
            let viewController = Environment.communityInterface.getPollDetailViewController(pollId: pollId)
            route(viewController)
        case .postList:
            guard let params = url.params(),
                  let storeId = params["storeId"] as? String else { return }
            
            let config = BossStorePostListViewModel.Config(storeId: storeId)
            let viewModel = BossStorePostListViewModel(config: config)
            let viewController = BossStorePostListViewController(viewModel: viewModel)
            route(viewController)
        case .browser:
            guard let params = url.params(),
                  let urlString = params["url"] as? String,
                  let url = URL(string: urlString),
                  UIApplication.shared.canOpenURL(url) else { return }
            
            UIApplication.shared.open(url)
        case .accountInfo:
            let config = AccountInfoViewModelConfig(shouldPush: false)
            let viewModel = Environment.membershipInterface.createAccountInfoViewModel(config: config)
            let viewController = Environment.membershipInterface.createAccountInfoViewController(viewModel: viewModel)
            
            guard let viewController else { return }
            route(viewController)
        case .unknown:
            os_log(.debug, "🔴알 수 없는 형태의 딥링크입니다. %{PUBLIC}@", urlString)
            break
        }
    }
    
    func handleReservedDeepLink() {
        guard let reservedDeepLink, canHandleDeepLink else { return }
        
        handle(reservedDeepLink)
        self.reservedDeepLink = nil
    }
    
    private func moveTab(_ tab: TabBarTag) {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        
        if let rootViewController {
            let topViewController = UIUtils.getTopViewController(rootViewController)
            if topViewController.isPanModalPresented == true {
                topViewController.dismiss(animated: true)
            }
        }
        
        if let navigationViewController = rootViewController as? UINavigationController,
           let tabBarViewController = navigationViewController.topViewController as? MainTabBarViewController {
            tabBarViewController.selectTab(tab: tab)
        }
    }
    
    private func isAppScheme(url: URL) -> Bool {
        return url.scheme == Bundle.deeplinkScheme && url.host.isNotNil
    }
    
    private func route(_ viewController: UIViewController) {
        guard let rootViewController = SceneDelegate.shared?.window?.rootViewController else { return }
        let topViewController = UIUtils.getTopViewController(rootViewController)
        
        if viewController is UINavigationController {
            topViewController.present(viewController, animated: true)
        } else if let navigationController = topViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let tabBarController = topViewController as? UITabBarController,
                  let navigationController = tabBarController.selectedViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if topViewController is PanModalPresentable {
            topViewController.dismiss(animated: true) { [weak self] in
                self?.route(viewController)
            }
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationStyle = .overCurrentContext
            topViewController.present(navigationController, animated: true)
        }
    }
    
    private func isDynamicLinkHost(url: URL) -> Bool {
        return url.host == URL(string: Bundle.dynamiclinkHost)?.host
    }
}
