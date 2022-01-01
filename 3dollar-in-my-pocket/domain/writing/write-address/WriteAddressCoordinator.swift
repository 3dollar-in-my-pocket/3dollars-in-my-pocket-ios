protocol WriteAddressCoordinator: AnyObject, Coordinator {
    func goToWriteDetail(address: String, location: (Double, Double))
}

extension WriteAddressCoordinator {
    func goToWriteDetail(address: String, location: (Double, Double)) {
        let viewController = WriteDetailVC.instance(address: address, location: location)
        
        viewController.deleagte = self as? WriteDetailDelegate
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
