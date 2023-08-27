import Foundation

import Model

public protocol DeeplinkManagerProtocol: AnyObject {
    func handleDynamiclink(url: URL?)
    
    func reserveDynamiclink(url: URL?)
    
    func handleDeeplink(url: URL?)
    
    func reserveDeeplink(deeplinkContents: DeepLinkContents)
    
    func flushDelayedDeeplink()
}
