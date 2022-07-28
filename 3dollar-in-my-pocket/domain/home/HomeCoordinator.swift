import UIKit

protocol HomeCoordinator: BaseCoordinator, AnyObject {
    func pushStoreDetail(storeId: String)
    func pushBossStoreDetail(storeId: String)
    func showDenyAlert()
    func goToAppSetting()
    func showSearchAddress()
    func presentVisit(store: Store)
}

extension HomeCoordinator where Self: UIViewController {
    func pushStoreDetail(storeId: String) {
        let storeDetailVC = StoreDetailViewController.instance(storeId: Int(storeId) ?? 0)
        
        self.presenter.navigationController?.pushViewController(
            storeDetailVC,
            animated: true
        )
    }
    
    func pushBossStoreDetail(storeId: String) {
        // TODO: 만들어야 함!
    }
    
    func showDenyAlert() {
        AlertUtils.showWithCancel(
            controller: self.presenter,
            title: "location_deny_title".localized,
            message: "location_deny_description".localized,
            okButtonTitle: "설정",
            onTapOk: self.goToAppSetting
        )
    }
    
    func goToAppSetting() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    func showSearchAddress() {
        let searchAddressVC = SearchAddressVC.instacne().then {
            $0.transitioningDelegate = self as? UIViewControllerTransitioningDelegate
            $0.delegate = self as? SearchAddressDelegate
        }
        
        self.presenter.tabBarController?.present(searchAddressVC, animated: true, completion: nil)
    }
    
    func presentVisit(store: Store) {
        let viewController = VisitViewController.instance(store: store)
        
        self.presenter.present(viewController, animated: true, completion: nil)
    }
}
