import UIKit

import RxSwift
import RxRelay

protocol DeeplinkManagerProtocol: AnyObject {
    func handleDeeplink(url: URL?)
    
    func reserveDeeplink(url: URL?)
    
    func reserveDeeplink(deeplinkContents: DeepLinkContents)
    
    func flushDelayedDeeplink()
}

final class DeeplinkManager: DeeplinkManagerProtocol {
    static let shared = DeeplinkManager()
    
    private var delayedDeeplink: DeepLinkContents?
    
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
    
    private func extractDeeplinkContents(url: URL?) -> DeepLinkContents? {
        guard let url = url,
        self.validateHost(host: url.host) else {
            Log.debug("URL 형식이 아닙니다.")
            return nil
        }
        
        var deeplinkContents: DeepLinkContents?
        
        switch DeeplinkType(rawValue: url.relativePath) {
        case .bookmark:
            guard let params = url.params(),
                  let param = params.first,
                  param.key == "folderId",
                  let folderId = param.value as? String else { return nil }
            let viewController = BookmarkViewerViewController.instance(folderId: folderId)
            deeplinkContents = DeepLinkContents(
                targetViewController: viewController,
                transitionType: .present
            )
            
        default:
            Log.debug("지원하는 Deeplink가 아닙니다.")
        }
        
        return deeplinkContents
    }
    
    private func navigateDeeplink(contents: DeepLinkContents) {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        
        switch contents.transitionType {
        case .push:
            if let navigationController = rootViewController as? UINavigationController {
                navigationController.pushViewController(
                    contents.targetViewController,
                    animated: true
                )
            } else {
                Log.error("UINavigationViewController가 없습니다.")
            }
            
        case .present:
            rootViewController?.present(contents.targetViewController, animated: true)
        }
    }
    
    private func validateHost(host: String?) -> Bool {
        return host == URL(string: Bundle.deeplinkHost)?.host
    }
}
