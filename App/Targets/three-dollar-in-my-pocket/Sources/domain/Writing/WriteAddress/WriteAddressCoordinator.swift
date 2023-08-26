protocol WriteAddressCoordinator: AnyObject, BaseCoordinator {
    func goToWriteDetail(address: String, location: Location)
    
    func presentConfirmPopup(address: String)
}

extension WriteAddressCoordinator where Self: BaseViewController {
    func goToWriteDetail(address: String, location: Location) {
        let viewController = WriteDetailViewController.instance(location: location, address: address)
        
        viewController.deleagte = self as? WriteDetailDelegate
        
        presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentConfirmPopup(address: String) {
        let viewController = AddressConfirmPopupViewController.instacne(address: address)
        
        viewController.delegate = self as? AddressConfirmPopupViewControllerDelegate
        presenter.present(viewController, animated: true, completion: nil)
    }
}
