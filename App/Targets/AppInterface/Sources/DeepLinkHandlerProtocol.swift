import Foundation

import Model

public protocol DeepLinkHandlerProtocol: AnyObject {
    func handle(_ urlString: String)
    
    func handleAdvertisementLink(_ advertisementLink: AdvertisementLinkResponse)
    
    func handleReservedDeepLink()
}
