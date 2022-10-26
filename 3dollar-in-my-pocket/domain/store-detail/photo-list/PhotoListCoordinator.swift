protocol PhotoListCoordinator: BaseCoordinator, AnyObject {
    func presentPhotoDetail(storeId: Int, selectedIndex: Int, photos: [Image])
}

extension PhotoListCoordinator where Self: PhotoListViewController {
    func presentPhotoDetail(storeId: Int, selectedIndex: Int, photos: [Image]) {
        let viewController = PhotoDetailVC.instance(
            storeId: storeId,
            index: selectedIndex,
            photos: photos
        ).then {
            $0.delegate = self as? PhotoDetailDelegate
        }
        
        
        self.present(viewController, animated: true, completion: nil)
    }
}
