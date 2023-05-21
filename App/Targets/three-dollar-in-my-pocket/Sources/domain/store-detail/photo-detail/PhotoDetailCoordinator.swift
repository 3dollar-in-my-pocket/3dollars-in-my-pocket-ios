protocol PhotoDetailCoordinator: BaseCoordinator, AnyObject {
    func dismiss()
    
    func showDeleteAlert()
}

extension PhotoDetailCoordinator where Self: PhotoDetailViewController {
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showDeleteAlert() {
        AlertUtils.showWithCancel(
            controller: self,
            title: "photo_detail_delete_title".localized,
            message: "photo_detail_delete_description".localized
        ) {
            self.reactor?.action.onNext(.deletePhoto)
        }
    }
}
