protocol NicknameCoordinator: BaseCoordinator, AnyObject {
    func presentPolicy()
    
    func goToMain(with bookmarkFolderId: String?)
}

extension NicknameCoordinator where Self: NicknameViewController {
    func presentPolicy() {
        let viewController = PolicyViewController.instance(delegate: self)
        
        self.present(viewController, animated: true)
    }
    
    func goToMain(with bookmarkFolderId: String?) {
        SceneDelegate.shared?.goToMain()
        
        if let bookmarkFolderId {
            let targetViewController = BookmarkViewerViewController.instance(
                folderId: bookmarkFolderId
            )
            let deepLinkContents = DeepLinkContents(
                targetViewController: targetViewController,
                transitionType: .present
            )
            DeeplinkManager.shared.reserveDeeplink(deeplinkContents: deepLinkContents)
        }
    }
}
