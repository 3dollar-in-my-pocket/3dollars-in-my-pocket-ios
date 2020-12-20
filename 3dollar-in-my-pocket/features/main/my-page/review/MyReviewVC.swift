import UIKit

class MyReviewVC: BaseVC {
    
    private lazy var myReviewView = MyReviewView(frame: self.view.frame)
    
    private var viewModel = MyReviewViewModel()
    
    private var currentPage = 1
    
    static func instance() -> MyReviewVC {
        return MyReviewVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = myReviewView
        
        setupTableView()
        getMyReviews()
    }
    
    override func bindViewModel() {
        myReviewView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupTableView() {
        myReviewView.tableView.delegate = self
        myReviewView.tableView.dataSource = self
        myReviewView.tableView.register(MyReviewCell.self, forCellReuseIdentifier: MyReviewCell.registerId)
    }
    
    private func getMyReviews() {
      ReviewService().getMyReview(page: 1)
        .subscribe(
        onNext: { [weak self] reviewPage in
          guard let self = self else { return }
          self.viewModel.review = reviewPage.content
          self.viewModel.totalCount = reviewPage.totalElements
          self.viewModel.totalPage = reviewPage.totalPages
          self.myReviewView.tableView.reloadData()
        },
          onError: self.showHTTPErrorAlert
        )
        .disposed(by: disposeBag)
    }
    
    private func loadMoreReview() {
        currentPage += 1
        addLoadingFooter()
      ReviewService().getMyReview(page: currentPage)
        .subscribe(
        onNext: { [weak self] reviewPage in
          guard let self = self else { return }
          
          self.viewModel.review.append(contentsOf: reviewPage.content)
          self.myReviewView.tableView.reloadData()
          self.removeLoadingFooter()
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          
          self.showHTTPErrorAlert(error: error)
          self.removeLoadingFooter()
        })
        .disposed(by: disposeBag)
    }
    
    func addLoadingFooter() {
        self.myReviewView.tableView.tableFooterView?.isHidden = false
    }
    
    func removeLoadingFooter() {
        self.myReviewView.tableView.tableFooterView?.isHidden = true
    }
}

extension MyReviewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.review.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyReviewCell.registerId, for: indexPath) as? MyReviewCell else {
            return BaseTableViewCell()
        }
        
        cell.bind(review: self.viewModel.review[indexPath.row])
        return cell
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
        if indexPath.row == self.viewModel.review.count - 1 && self.currentPage < self.viewModel.totalPage {
            self.loadMoreReview()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let storeId = self.viewModel.review[indexPath.row].storeId
      
      self.navigationController?.pushViewController(DetailVC.instance(storeId: storeId), animated: true)
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
