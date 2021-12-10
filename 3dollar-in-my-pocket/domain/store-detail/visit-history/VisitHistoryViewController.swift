import UIKit

protocol VisitHistoryViewControllerDelegate: AnyObject {
    func onDismiss()
}

final class VisitHistoryViewController: BaseVC, VisitHistoryCoordinator {
    weak var delegate: VisitHistoryViewControllerDelegate?
    private var coordinator: VisitHistoryCoordinator?
    private let visitHistoryView = VisitHistoryView()
    private let viewModel: VisitHistoryViewModel
    
    static func instance(visitHistories: [VisitHistory]) -> VisitHistoryViewController {
        return VisitHistoryViewController(visitHistories: visitHistories).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init(visitHistories: [VisitHistory]) {
        self.viewModel = VisitHistoryViewModel(visitHistories: visitHistories)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.visitHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func bindEvent() {
        self.visitHistoryView.closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
                self?.delegate?.onDismiss()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.visitHistories
            .asDriver(onErrorJustReturn: [])
            .drive(self.visitHistoryView.rx.visitHistories)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.visitHistories
            .asDriver(onErrorJustReturn: [])
            .drive(self.visitHistoryView.tableView.rx.items(
                cellIdentifier: VisitHistoryTableViewCell.registerId,
                cellType: VisitHistoryTableViewCell.self
            )) { _, visitHistory, cell in
                cell.bind(visitHistory: visitHistory)
            }
            .disposed(by: self.disposeBag)
    }
}
