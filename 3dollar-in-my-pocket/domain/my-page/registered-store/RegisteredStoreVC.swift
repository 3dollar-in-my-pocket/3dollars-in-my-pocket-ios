import UIKit
import RxSwift

class RegisteredVC: BaseVC {
  
  private lazy var registeredStoreView = RegisteredStoreView(frame: self.view.frame)
  private let viewModel = RegisteredStoreViewModel(
    storeService: StoreService(),
    userDefaults: UserDefaultsUtil()
  )
  
  
  static func instance() -> RegisteredVC {
    return RegisteredVC(nibName: nil, bundle: nil).then {
      $0.hidesBottomBarWhenPushed = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view = registeredStoreView
    self.setupTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tabBarController?.tabBar.barTintColor = UIColor(r: 46, g: 46, b: 46)
    LocationManager.shared.getCurrentLocation()
      .bind(to: self.viewModel.input.fetchStores)
      .disposed(by: self.disposeBag)
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.stores
      .bind(to: self.registeredStoreView.tableView.rx.items(
              cellIdentifier: RegisteredStoreCell.registerId,
              cellType: RegisteredStoreCell.self
      )) { row, store, cell in
        cell.bind(store: store)
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.isHiddenFooter
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.setHiddenLoadingFooter(isHidden:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToStoreDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToStoreDetail(storeId:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.registeredStoreView.backButton.rx.tap
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func setupTableView() {
    self.registeredStoreView.tableView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    self.registeredStoreView.tableView.register(
      RegisteredStoreCell.self,
      forCellReuseIdentifier: RegisteredStoreCell.registerId
    )
    self.registeredStoreView.tableView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapStore)
      .disposed(by: disposeBag)
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func goToStoreDetail(storeId: Int) {
    let storeDetailVC = StoreDetailVC.instance(storeId: storeId)
    
    self.navigationController?.pushViewController(storeDetailVC, animated: true)
  }
  
  func setHiddenLoadingFooter(isHidden: Bool) {
    self.registeredStoreView.tableView.tableFooterView?.isHidden = isHidden
  }
}

extension RegisteredVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return RegisteredStoreHeader().then {
      $0.setCount(count: self.viewModel.totalCount ?? 0)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    self.viewModel.input.loadMore.onNext(indexPath.row)
  }
}
