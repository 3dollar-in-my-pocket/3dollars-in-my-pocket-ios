import UIKit

protocol DeeplinkManagerProtocol: AnyObject {
    func handleDeeplink(url: URL?)
}

final class DeeplinkManager: DeeplinkManagerProtocol {
    static let shared = DeeplinkManager()
    
    func handleDeeplink(url: URL?) {
        guard let url = url,
        self.validateHost(host: url.host) else {
            Log.debug("URL 형식이 아닙니다.")
            return
        }
        
        switch DeeplinkType(rawValue: url.relativePath) {
        case .bookmark:
            guard let params = url.params(),
                  let param = params.first,
                  param.key == "folderId",
                  let folderId = param.value as? String else { return }
            let viewController = BookmarkViewerViewController.instance(folderId: folderId)
            
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController?.present(viewController, animated: true)
            }
            
            
            Log.debug("params: \(url.params())")
            
        default:
            Log.debug("지원하는 Deeplink가 아닙니다.")
            break
        }
    }
    
    private func validateHost(host: String?) -> Bool {
        return host == URL(string: Bundle.deeplinkHost)?.host
    }
}
