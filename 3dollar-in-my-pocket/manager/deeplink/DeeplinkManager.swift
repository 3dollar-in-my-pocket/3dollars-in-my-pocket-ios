import UIKit

import RxSwift
import RxRelay

protocol DeeplinkManagerProtocol: AnyObject {
    var deeplinkPublisher: PublishRelay<DeepLinkContents> { get }
    
    func handleDeeplink(url: URL?)
}

final class DeeplinkManager: DeeplinkManagerProtocol {
    static let shared = DeeplinkManager()
    
    let deeplinkPublisher = PublishRelay<DeepLinkContents>()
    
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
            let deeplinkContents = DeepLinkContents(
                targetViewController: viewController,
                transitionType: .present
            )
            
            self.deeplinkPublisher.accept(deeplinkContents)
        default:
            Log.debug("지원하는 Deeplink가 아닙니다.")
            break
        }
    }
    
    private func validateHost(host: String?) -> Bool {
        return host == URL(string: Bundle.deeplinkHost)?.host
    }
}

