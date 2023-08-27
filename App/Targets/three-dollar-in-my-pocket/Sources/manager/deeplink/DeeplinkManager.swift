import UIKit

import AppInterface
import Model

import RxSwift
import RxRelay

final class DeeplinkManager: DeeplinkManagerProtocol {
    
    static let shared = DeeplinkManager()
    
    private var delayedDeeplink: DeepLinkContents?
    
    func handleDynamiclink(url: URL?) {
        guard let deeplinkContents = self.extractDynamiclinkContents(url: url) else { return }
        
        self.navigateDeeplink(contents: deeplinkContents)
    }
    
    func reserveDynamiclink(url: URL?) {
        guard let deeplinkContents = self.extractDynamiclinkContents(url: url) else { return }
        
        self.delayedDeeplink = deeplinkContents
    }
    
    func handleDeeplink(url: URL?) {
        guard let deeplinkContents = self.extractDeeplinkContents(url: url) else { return }
        
        self.navigateDeeplink(contents: deeplinkContents)
    }
    
    func reserveDeeplink(url: URL?) {
        guard let deeplinkContents = self.extractDeeplinkContents(url: url) else { return }
        
        self.delayedDeeplink = deeplinkContents
    }
    
    func reserveDeeplink(deeplinkContents: DeepLinkContents) {
        self.delayedDeeplink = deeplinkContents
    }
    
    func flushDelayedDeeplink() {
        guard let delayedDeeplink = self.delayedDeeplink else { return }
        
        self.navigateDeeplink(contents: delayedDeeplink)
        self.delayedDeeplink = nil
    }
    
    private func extractDynamiclinkContents(url: URL?) -> DeepLinkContents? {
        guard let url = url,
        self.validateHost(host: url.host) else {
            Log.debug("URL 형식이 아닙니다.")
            return nil
        }
        
        var deeplinkContents: DeepLinkContents?
        
        switch DeeplinkType(rawValue: "/\(url.relativePath)") {
        case .bookmark:
            deeplinkContents = self.createBookmarkContents(query: url.params())
            
        case .store:
            deeplinkContents = self.createStoreDetailContents(query: url.params())
            
        default:
            Log.debug("지원하는 Deeplink가 아닙니다.")
        }
        
        return deeplinkContents
    }
    
    private func extractDeeplinkContents(url: URL?) -> DeepLinkContents? {
        guard let url = url,
              self.validateScheme(scheme: url.scheme),
              let host = url.host else {
            Log.debug("올바른 딥링크 형식이 아닙니다.")
            return nil
        }
        
        var deeplinkContents: DeepLinkContents?
        
        switch DeeplinkType(rawValue: host + url.path) {
        case .bookmark:
            deeplinkContents = self.createBookmarkContents(query: url.params())
            
        case .store:
            deeplinkContents = self.createStoreDetailContents(query: url.params())
            
        case .home:
            deeplinkContents = self.createHomeContents()
            
        case .medal:
            deeplinkContents = self.createMedalContents()
            
        default:
            Log.debug("지원하는 Deeplink가 아닙니다.")
            
        }
        
        return deeplinkContents
    }
    
    private func validateScheme(scheme: String?) -> Bool {
        return scheme == Bundle.deeplinkScheme
    }
    
    private func navigateDeeplink(contents: DeepLinkContents) {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        
        if let tab = contents.selectedTab {
            if let tabBarViewController = rootViewController as? TabBarVC {
                tabBarViewController.selectTab(tab: tab)
            }
        }
        
        guard let transitionType = contents.transitionType,
              let targetViewController = contents.targetViewController else { return }
        
        switch transitionType {
        case .push:
            if let navigationController = rootViewController as? UINavigationController {
                navigationController.pushViewController(
                    targetViewController,
                    animated: true
                )
            } else if let tabBarViewController = rootViewController as? TabBarVC,
                 let navigationController
                        = tabBarViewController.selectedViewController as? UINavigationController {
                navigationController.pushViewController(
                    targetViewController,
                    animated: true
                )
            } else if rootViewController is SplashVC {
                self.reserveDeeplink(deeplinkContents: contents)
            } else {
                Log.error("UINavigationViewController가 없습니다.")
            }
            
        case .present:
            rootViewController?.present(targetViewController, animated: true)
        }
    }
    
    private func validateHost(host: String?) -> Bool {
        return host == URL(string: Bundle.dynamiclinkHost)?.host
    }
    
    private func createBookmarkContents(query: [String: Any]?) -> DeepLinkContents? {
        guard let query = query,
              let param = query.first,
              param.key == "folderId",
              let folderId = param.value as? String else { return nil }
        let viewController = BookmarkViewerViewController.instance(folderId: folderId)
        
        return DeepLinkContents(
            targetViewController: viewController,
            transitionType: .present
        )
    }
    
    private func createStoreDetailContents(query: [String: Any]?) -> DeepLinkContents? {
        guard let query = query,
              let storeTypeString = query["storeType"] as? String,
              let storeId = query["storeId"] as? String else { return nil }
        
        var viewController: UIViewController
        switch StoreType(value: storeTypeString) {
        case .streetFood:
            viewController = StoreDetailViewController.instance(storeId: Int(storeId) ?? 0)
            
        case .foodTruck:
            viewController = BossStoreDetailViewController.instance(storeId: storeId)
            
        case .unknown:
            Log.debug("알 수 없는 storeType 입니다.")
            return nil
        }
        
        return DeepLinkContents(
            targetViewController: viewController,
            transitionType: .push
        )
    }
    
    private func createHomeContents() -> DeepLinkContents {
        return DeepLinkContents(selectedTab: .home)
    }
    
    private func createMedalContents() -> DeepLinkContents {
        let targetViewController = MyMedalViewController.instance()
        
        return DeepLinkContents(
            targetViewController: targetViewController,
            transitionType: .push
        )
    }
}
