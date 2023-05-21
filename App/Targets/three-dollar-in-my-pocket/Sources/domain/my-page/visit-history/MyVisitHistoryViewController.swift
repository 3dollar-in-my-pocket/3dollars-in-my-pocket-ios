import UIKit

final class MyVisitHistoryViewController: BaseVC, MyVisitHistoryCoordinator {
    private var coordinator: MyVisitHistoryCoordinator?
    private let myVisitHistoryView = MyVisitHistoryView()
    private let viewModel = MyVisitHistoryViewModel(historyService: VisitHistoryService())
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> MyVisitHistoryViewController {
        return MyVisitHistoryViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.myVisitHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func bindEvent() {
        self.myVisitHistoryView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popup()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelInput() {
        self.myVisitHistoryView.tableView.rx.itemSelected
            .map { $0.row }
            .bind(to: self.viewModel.input.tapVisitHistory)
            .disposed(by: self.disposeBag)
        
        self.myVisitHistoryView.tableView.rx.willDisplayCell
            .map { $0.indexPath.row }
            .bind(to: self.viewModel.input.willDisplayCell)
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.isHiddenFooter
            .asDriver(onErrorJustReturn: true)
            .drive(self.myVisitHistoryView.tableView.rx.isFooterHidden)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.visitHistoriesPublisher
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] visitHistories in
                self?.myVisitHistoryView.emptyView.isHidden = !visitHistories.isEmpty
            })
            .drive(self.myVisitHistoryView.tableView.rx.items(
                    cellIdentifier: MyVisitHistoryTableViewCell.registerId,
                    cellType: MyVisitHistoryTableViewCell.self
            )) { _, visitHitory, cell in
                cell.bind(visitHistory: visitHitory)
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.goToStoreDetail
            .asDriver(onErrorJustReturn: -1)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.goToStoreDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
}
