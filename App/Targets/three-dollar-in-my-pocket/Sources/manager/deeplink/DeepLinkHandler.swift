import UIKit
import OSLog

import Common
import AppInterface
import Model
import Store
import StoreInterface
import MembershipInterface
import MyPage

import PanModal

final class DeepLinkHandler: DeepLinkHandlerProtocol {
    static let shared = DeepLinkHandler()

    private var canHandleDeepLink: Bool {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController

        if let navigationViewController = rootViewController as? UINavigationController {
            if navigationViewController.topViewController is MainTabBarViewController {
                return true
            } else if navigationViewController.topViewController is BaseViewController {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    private var reservedDeepLink: String?

    private var mainTabBarViewController: MainTabBarViewController? {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        let navigationViewController = rootViewController as? UINavigationController

        return navigationViewController?.topViewController as? MainTabBarViewController
    }

    func reservedDeepLinkExisted() -> Bool {
        return reservedDeepLink.isNotNil
    }

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

    func handleLinkResponse(_ linkResponse: SDLink) {
        switch linkResponse.type {
        case .appScheme:
            let urlString = "\(Bundle.deeplinkScheme):/\(linkResponse.link)"
            handle(urlString)
        case .web:
            let urlString = "\(Bundle.deeplinkScheme)://browser?url=\(linkResponse.link)"
            handle(urlString)
        case .store:
            let urlString = "\(Bundle.deeplinkScheme):/\(linkResponse.link)"
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
        var path: String?

        if isUniversalLinkHost(url: url) {
            path = url.relativePath.replacingOccurrences(of: "/", with: "")
        }

        if isAppScheme(url: url) {
            path = (url.host ?? "") + url.path
        }

        guard let path else { return }

        if handleStoreSectionLinkIfNeeded(path: path, url: url) { return }

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
                  let storeId = intParam(params, key: "storeId") else { return }

            route(Environment.storeInterface.getStoreDetailFullScreenViewController(storeId: storeId))
        case .home:
            moveTab(.home)

            if let params = url.params(),
               let preset = params["preset"] as? String {
                mainTabBarViewController?.applyHomePreset(preset)
            }
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
                  let storeId = intParam(params, key: "storeId") else { return }

            let storeDetailViewController = Environment.storeInterface.getStoreDetailFullScreenViewController(storeId: storeId)
            route(storeDetailViewController)

            let config = BossStorePostListViewModel.Config(storeId: String(storeId))
            let viewModel = BossStorePostListViewModel(config: config)
            let viewController = BossStorePostListViewController(viewModel: viewModel)
            route(viewController)
        case .browser:
            guard let params = url.params(),
                  let urlString = params["url"] as? String else { return }
            let title = params["title"] as? String

            let webViewController = WebViewController(title: title, url: urlString)
            route(webViewController)
        case .accountInfo:
            let config = AccountInfoViewModelConfig(shouldPush: false)
            let viewModel = Environment.membershipInterface.createAccountInfoViewModel(config: config)
            let viewController = Environment.membershipInterface.createAccountInfoViewController(viewModel: viewModel)

            guard let viewController else { return }
            route(viewController)
        case .reviewList:
            guard let params = url.params(),
                  let storeId = intParam(params, key: "storeId") else { return }

            route(Environment.storeInterface.getStoreDetailFullScreenViewController(storeId: storeId))
            let config = ReviewListViewModel.Config(storeId: storeId, isBossStore: false)
            let viewModel = ReviewListViewModel(config: config)
            let viewController = ReviewListViewControlelr.instance(viewModel: viewModel)
            route(viewController)
        case .visit:
            guard let params = url.params(),
                  let storeId = params["storeId"] as? String else { return }

            let config = VisitViewModel.Config(storeId: storeId)
            let viewModel = VisitViewModel(config: config)
            let viewController = VisitViewController(viewModel: viewModel)
            route(viewController, forcePresent: true)
        case .myCoupons:
            let storeDetailViewController = Environment.storeInterface.getCouponListViewController(onReload: {})
            route(storeDetailViewController)
        case .storeImages:
            guard let params = url.params(),
                  let storeId = intParam(params, key: "storeId") else { return }

            route(Environment.storeInterface.getPhotoListViewController(storeId: storeId))
        case .unknown:
            os_log(.debug, "🔴알 수 없는 형태의 딥링크입니다. %{PUBLIC}@", urlString)
        }
    }

    func handleReservedDeepLink() {
        guard let reservedDeepLink, canHandleDeepLink else { return }

        handle(reservedDeepLink)
        self.reservedDeepLink = nil
    }

    /// "stores/{storeId}#section" 형태 링크. 같은 가게 상세가 이미 떠 있으면 해당 섹션으로 스크롤만 하고,
    /// 아니면 전체 화면 상세를 연 뒤 섹션 데이터 로드가 끝나면 스크롤되도록 요청을 걸어둔다.
    private func handleStoreSectionLinkIfNeeded(path: String, url: URL) -> Bool {
        let pathComponents = path.split(separator: "/").map(String.init)
        guard pathComponents.count == 2,
              pathComponents[0] == "stores",
              let storeId = Int(pathComponents[1]) else { return false }

        if let scrollable = findStoreSectionScrollable(storeId: storeId) {
            if let fragment = url.fragment {
                scrollable.scrollToSection(fragment: fragment)
            }
            return true
        }

        let viewController = Environment.storeInterface.getStoreDetailFullScreenViewController(storeId: storeId)
        route(viewController)
        if let fragment = url.fragment {
            (viewController as? StoreSectionScrollable)?.scrollToSection(fragment: fragment)
        }
        return true
    }

    private func findStoreSectionScrollable(storeId: Int) -> StoreSectionScrollable? {
        guard let rootViewController = SceneDelegate.shared?.window?.rootViewController else { return nil }
        let topViewController = UIUtils.getTopViewController(rootViewController)

        return findStoreSectionScrollable(in: topViewController, storeId: storeId)
    }

    private func findStoreSectionScrollable(in viewController: UIViewController, storeId: Int) -> StoreSectionScrollable? {
        if let scrollable = viewController as? StoreSectionScrollable, scrollable.scrollableStoreId == storeId {
            return scrollable
        }
        for child in viewController.children {
            if let scrollable = findStoreSectionScrollable(in: child, storeId: storeId) {
                return scrollable
            }
        }
        return nil
    }

    private func moveTab(_ tab: TabBarTag) {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController

        if let rootViewController {
            let topViewController = UIUtils.getTopViewController(rootViewController)
            if topViewController.isPanModalPresented == true {
                topViewController.dismiss(animated: true)
            }
        }

        mainTabBarViewController?.selectTab(tab: tab)
    }

    /// 쿼리 파라미터는 문자열로 파싱되므로 숫자 id 는 여기서 변환한다.
    private func intParam(_ params: [String: Any], key: String) -> Int? {
        if let value = params[key] as? Int { return value }
        if let value = params[key] as? String { return Int(value) }
        return nil
    }

    private func isAppScheme(url: URL) -> Bool {
        return url.scheme == Bundle.deeplinkScheme && url.host.isNotNil
    }

    private func route(_ viewController: UIViewController, forcePresent: Bool = false) {
        guard let rootViewController = SceneDelegate.shared?.window?.rootViewController else { return }
        let topViewController = UIUtils.getTopViewController(rootViewController)

        if forcePresent {
            if topViewController is PanModalPresentable {
                topViewController.dismiss(animated: true) { [weak self] in
                    self?.route(viewController, forcePresent: true)
                }
            } else {
                topViewController.present(viewController, animated: true)
            }
        }

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

    private func isUniversalLinkHost(url: URL) -> Bool {
        return url.host == URL(string: Bundle.universialLinkHost)?.host
    }
}
