import UIKit

protocol DeeplinkManagerProtocol: AnyObject {
    func handleDeeplink(url: URL?)
}

final class DeeplinkManager: DeeplinkManagerProtocol {
    static let shared = DeeplinkManager()
    
    func handleDeeplink(url: URL?) {
        guard let url = url,
        let host = url.host else {
            Log.debug("URL 형식이 아닙니다.")
            return
        }
        Log.debug(
                """
                \nurl: \(url.absoluteString)
                host: \(url.host)
                path: \(url.pathComponents)
                params: \(url.params())
                """
        )
    }
    
    private func validateHost(host: String) -> Bool {
        return false
    }
}
