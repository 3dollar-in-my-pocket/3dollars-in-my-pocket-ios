import UIKit

protocol BossStoreDetailCoordinator: AnyObject, BaseCoordinator {
    func pushFeedback(storeId: String)
    
    func pushURL(url: String?)
}

extension BossStoreDetailCoordinator {
    func pushFeedback(storeId: String) {
        
    }
    
    func pushURL(url: String?) {
        guard let urlString = url,
              let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
}
