import UIKit

class RegisteredVC: BaseVC {
    
    private lazy var registeredView = RegisteredView(frame: self.view.frame)
    
    private var viewModel = RegisteredViewModel()
    
    private var currentPage = 1
    
    static func instance() -> RegisteredVC {
        return RegisteredVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = registeredView
        setupTableView()
        getReportedStore()
    }
    
    override func bindViewModel() {
        registeredView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupTableView() {
        registeredView.tableView.delegate = self
        registeredView.tableView.dataSource = self
        registeredView.tableView.register(RegisteredCell.self, forCellReuseIdentifier: RegisteredCell.registerId)
    }
    
    private func getReportedStore() {
      StoreService().getReportedStore(page: 1).subscribe(
        onNext: { [weak self] storePage in
          guard let self = self else { return }
          
          self.viewModel.stores = storePage.content
          self.viewModel.totalCount = storePage.totalElements
          self.viewModel.totalPage = storePage.totalPages
          self.registeredView.tableView.reloadData()
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
              self.registeredView.tableView.reloadData()
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
        self.registeredView.tableView.tableFooterView?.isHidden = false
    }
    
    func removeLoadingFooter() {
        self.registeredView.tableView.tableFooterView?.isHidden = true
    }
}

extension RegisteredVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RegisteredCell.registerId, for: indexPath) as? RegisteredCell else {
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
        return RegisteredHeader().then {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y

        if 130 - contentOffset > 0 && contentOffset > 0 && scrollView.contentSize.height > scrollView.frame.height {
            self.registeredView.bgCloud.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(98 - contentOffset)
            }
            self.registeredView.bgCloud.alpha = CGFloat((130 - contentOffset)/(130/0.2))
        }
    }

}