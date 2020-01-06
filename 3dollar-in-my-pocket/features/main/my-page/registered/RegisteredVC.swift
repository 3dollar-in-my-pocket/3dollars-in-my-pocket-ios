import UIKit

class RegisteredVC: BaseVC {
    
    private lazy var registeredView = RegisteredView(frame: self.view.frame)
    
    static func instance() -> RegisteredVC {
        return RegisteredVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = registeredView
        registeredView.tableView.delegate = self
        registeredView.tableView.dataSource = self
        registeredView.tableView.register(RegisteredCell.self, forCellReuseIdentifier: RegisteredCell.registerId)
    }
    
    override func bindViewModel() {
        registeredView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension RegisteredVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RegisteredCell.registerId, for: indexPath) as? RegisteredCell else {
            return BaseTableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return RegisteredHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
