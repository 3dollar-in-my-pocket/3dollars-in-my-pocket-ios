protocol PhotoListCoordinator: BaseCoordinator, AnyObject {
    func presentPhotoDetail(storeId: Int, selectedIndex: Int, photos: [Image])
}

extension PhotoListCoordinator where Self: PhotoListViewController {
    func presentPhotoDetail(storeId: Int, selectedIndex: Int, photos: [Image]) {
        let viewController = PhotoDetailViewController.instance(
            storeId: storeId,
            index: selectedIndex,
            photos: photos
        )
        
        self.present(viewController, animated: true, completion: nil)
    }
}
