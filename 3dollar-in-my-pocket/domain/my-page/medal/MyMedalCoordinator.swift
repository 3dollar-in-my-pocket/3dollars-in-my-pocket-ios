protocol MyMedalCoordinator: Coordinator, AnyObject {
    func showMedalInfo()
}

extension MyMedalCoordinator {
    func showMedalInfo() {
        let viewController = MedalInfoViewController.instance()
        
        self.presenter.present(viewController, animated: true, completion: nil)
    }
}
