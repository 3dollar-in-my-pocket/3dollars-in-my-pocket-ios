import UIKit

final class VisitHistoryViewController: BaseViewController, VisitHistoryCoordinator {
    private var coordinator: VisitHistoryCoordinator?
    private let visitHistoryView = VisitHistoryView()
    
    static func instance(visitHistories: [VisitHistory]) -> VisitHistoryViewController {
        return VisitHistoryViewController(visitHistories: visitHistories).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init(visitHistories: [VisitHistory]) {
        super.init(nibName: nil, bundle: nil)
        
        self.visitHistoryView.bind(visitHistories: visitHistories)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.visitHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.visitHistoryView.closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.visitHistoryView.tapBackgroundGesture.rx.event
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
    }
}
