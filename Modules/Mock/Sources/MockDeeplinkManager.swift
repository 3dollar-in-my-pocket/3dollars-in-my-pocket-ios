import Foundation

import Model
import AppInterface

final class MockDeeplinkManager: DeeplinkManagerProtocol {
    func handleDynamiclink(url: URL?) { }
    
    func reserveDynamiclink(url: URL?) { }
    
    func handleDeeplink(url: URL?) { }
    
    func reserveDeeplink(deeplinkContents: Model.DeepLinkContents) { }
    
    func flushDelayedDeeplink() { }
}
