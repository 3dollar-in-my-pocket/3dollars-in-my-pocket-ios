import UIKit

class RegisteredVC: BaseVC {
    
    private lazy var registeredStoreView = RegisteredStoreView(frame: self.view.frame)
    
    private var viewModel = RegisteredStoreViewModel()
    
    private var currentPage = 1
    
    static func instance() -> RegisteredVC {
        return RegisteredVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = registeredStoreView
        setupTableView()
        getReportedStore()
    }
    
    override func bindViewModel() {
      registeredStoreView.backButton.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupTableView() {
        registeredStoreView.tableView.delegate = self
        registeredStoreView.tableView.dataSource = self
        registeredStoreView.tableView.register(RegisteredStoreCell.self, forCellReuseIdentifier: RegisteredStoreCell.registerId)
    }
    
    private func getReportedStore() {
      StoreService().getReportedStore(page: 1).subscribe(
        onNext: { [weak self] storePage in
          guard let self = self else { return }
          self.viewModel.stores = storePage.content
          self.viewModel.totalCount = storePage.totalElements
          self.viewModel.totalPage = storePage.totalPages
          self.registeredStoreView.tableView.reloadData()
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            self.showHTTPErrorAlert(error: httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)
            
            self.showSystemAlert(alert: alertContent)
          }
        })
        .disposed(by: disposeBag)
    }
    
    private func loadMoreStore() {
        currentPage += 1
        addLoadingFooter()
        StoreService().getReportedStore(page: currentPage)
          .subscribe(
            onNext: { [weak self] storePage in
              guard let self = self else { return }
              self.viewModel.stores.append(contentsOf: storePage.content)
              self.registeredStoreView.tableView.reloadData()
              self.removeLoadingFooter()
            },
            onError: { [weak self] error in
              guard let self = self else { return }
              
              if let httpError = error as? HTTPError {
                self.showHTTPErrorAlert(error: httpError)
              } else if let error = error as? CommonError {
                let alertContent = AlertContent(title: nil, message: error.description)
                
                self.showSystemAlert(alert: alertContent)
              }
              self.removeLoadingFooter()
            })
          .disposed(by: disposeBag)
    }
    
    func addLoadingFooter() {
        self.registeredStoreView.tableView.tableFooterView?.isHidden = false
    }
    
    func removeLoadingFooter() {
        self.registeredStoreView.tableView.tableFooterView?.isHidden = true
    }
}

extension RegisteredVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RegisteredStoreCell.registerId, for: indexPath) as? RegisteredStoreCell else {
            return BaseTableViewCell()
        }
        
        cell.bind(store: self.viewModel.stores[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let storeId = self.viewModel.stores[indexPath.row].id
      
      self.navigationController?.pushViewController(StoreDetailVC.instance(storeId: storeId), animated: true)  
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return RegisteredStoreHeader().then {
            $0.setCount(count: self.viewModel.totalCount)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.viewModel.stores.count - 1 && self.currentPage < self.viewModel.totalPage {
            self.loadMoreStore()
        }
    }
}
