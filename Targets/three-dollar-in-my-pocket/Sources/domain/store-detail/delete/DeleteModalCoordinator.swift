protocol DeleteModalCoordinator: BaseCoordinator, AnyObject {
    func dismissOnRequest()
    
    func dismiss()
}

extension DeleteModalCoordinator where Self: DeleteModalViewController {
    func dismissOnRequest() {
        self.deleagete?.onRequest()
        DimManager.shared.hideDim()
        self.dismiss(animated: true)
    }
    
    func dismiss() {
        DimManager.shared.hideDim()
        self.dismiss(animated: true)
    }
}
