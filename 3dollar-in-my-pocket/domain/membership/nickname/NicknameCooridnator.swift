protocol NicknameCoordinator: BaseCoordinator, AnyObject {
    func presentPolicy()
    
    func goToMain()
}

extension NicknameCoordinator where Self: NicknameViewController {
    func presentPolicy() {
        let viewController = PolicyViewController.instance(delegate: self)
        
        self.present(viewController, animated: true)
    }
    
    func goToMain() {
        SceneDelegate.shared?.goToMain()
    }
}
