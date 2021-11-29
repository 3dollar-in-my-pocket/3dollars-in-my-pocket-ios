import UIKit
import RxSwift

final class RegisteredStoreViewController: BaseVC, RegisteredStoreCoordinator {
    private weak var coordinator: RegisteredStoreCoordinator?
    private let registeredStoreView = RegisteredStoreView()
    private let viewModel = RegisteredStoreViewModel(
        storeService: StoreService(),
        userDefaults: UserDefaultsUtil()
    )
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> RegisteredStoreViewController {
        return RegisteredStoreViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.registeredStoreView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.barTintColor = UIColor(r: 46, g: 46, b: 46)
    }
    
    override func bindEvent() {
        self.registeredStoreView.backButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.popup()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelInput() {
        self.registeredStoreView.tableView.rx.willDisplayCell
            .map { $0.indexPath.row }
            .bind(to: self.viewModel.input.loadMore)
            .disposed(by: self.disposeBag)
        
        self.registeredStoreView.tableView.rx.itemSelected
            .map { $0.row }
            .bind(to: self.viewModel.input.tapStore)
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.stores
            .asDriver(onErrorJustReturn: [])
            .drive(self.registeredStoreView.tableView.rx.items(
                    cellIdentifier: RegisteredStoreCell.registerId,
                    cellType: RegisteredStoreCell.self
            )) { _, store, cell in
                cell.bind(store: store)
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.totalStoreCount
            .asDriver(onErrorJustReturn: 0)
            .drive(self.registeredStoreView.rx.storeCounts)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.isHiddenFooter
            .asDriver(onErrorJustReturn: false)
            .drive(self.registeredStoreView.rx.isHiddenFooter)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.goToStoreDetail
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.goToStoreDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
    }
}
