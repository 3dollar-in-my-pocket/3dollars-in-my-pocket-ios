import Foundation

import Model
import AppInterface

final class MockDeepLinkHandler: DeepLinkHandlerProtocol {
    func handle(_ urlString: String) { }
    
    func handleAdvertisementLink(_ advertisementLink: AdvertisementLinkResponse) { }
    
    func handleReservedDeepLink() { }
    
    func handleLinkResponse(_ linkResponse: LinkResponse) { }
}
