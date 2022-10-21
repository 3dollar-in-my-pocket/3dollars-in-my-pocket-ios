protocol VisitHistoryCoordinator: BaseCoordinator, AnyObject {
    func dismiss()
}

extension VisitHistoryCoordinator where Self: VisitHistoryViewController {
    func dismiss() {
        DimManager.shared.hideDim()
        self.dismiss(animated: true, completion: nil)
    }
}
