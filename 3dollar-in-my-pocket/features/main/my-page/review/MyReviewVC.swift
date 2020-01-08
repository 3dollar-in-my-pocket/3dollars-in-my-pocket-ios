import UIKit

class MyReviewVC: BaseVC {
    
    private lazy var myReviewView = MyReviewView(frame: self.view.frame)
    
    
    static func instance() -> MyReviewVC {
        return MyReviewVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = myReviewView
        
        myReviewView.tableView.delegate = self
        myReviewView.tableView.dataSource = self
        myReviewView.tableView.register(MyReviewCell.self, forCellReuseIdentifier: MyReviewCell.registerId)
    }
    
    override func bindViewModel() {
        myReviewView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MyReviewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyReviewCell.registerId, for: indexPath) as? MyReviewCell else {
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
            self.myReviewView.bgCloud.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(98 - contentOffset)
            }
            self.myReviewView.bgCloud.alpha = CGFloat((130 - contentOffset)/(130/0.2))
        }
    }
}
