import UIKit
import RxSwift

class MyReviewVC: BaseVC {
  
  private lazy var myReviewView = MyReviewView(frame: self.view.frame)
  private let viewModel = MyReviewViewModel(reviewService: ReviewService())
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  static func instance() -> MyReviewVC {
    return MyReviewVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view = myReviewView
    self.setupTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tabBarController?.tabBar.barTintColor = UIColor(r: 46, g: 46, b: 46)
    self.viewModel.input.viewDidLoad.onNext(())
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.reviews
      .bind(to: self.myReviewView.tableView.rx.items(
              cellIdentifier: MyReviewCell.registerId,
              cellType: MyReviewCell.self
      )) { row, review, cell in
        cell.bind(review: review)
        cell.moreButton.rx.tap
          .map { row }
          .bind(onNext: self.showMoreActionSheet(reviewId:))
          .disposed(by: cell.disposeBag)
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
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showRootLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.myReviewView.backButton.rx.tap
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func setupTableView() {
    self.myReviewView.tableView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    self.myReviewView.tableView.register(
      MyReviewCell.self, forCellReuseIdentifier:
        MyReviewCell.registerId
    )
    self.myReviewView.tableView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapReview)
      .disposed(by: disposeBag)
  }
  
  private func setHiddenLoadingFooter(isHidden: Bool){
    self.myReviewView.tableView.tableFooterView?.isHidden = isHidden
  }
  
  private func goToStoreDetail(storeId: Int) {
    let storeDetailVC = StoreDetailVC.instance(storeId: storeId)
    
    self.navigationController?.pushViewController(storeDetailVC, animated: true)
  }
  
  private func showMoreActionSheet(reviewId: Int) {
    let alertController = UIAlertController(title: nil, message: "옵션", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(
      title: "store_detail_delete_review".localized,
      style: .destructive
    ) { _ in
      self.viewModel.input.deleteReview.onNext(reviewId)
    }
    let cancelAction = UIAlertAction(
      title: "store_detail_cancel".localized,
      style: .cancel
    ) { _ in }
    
    alertController.addAction(deleteAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
}

extension MyReviewVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return MyReviewHeaderView().then {
      $0.setCount(count: self.viewModel.totalCount ?? 0)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    self.viewModel.input.loadMore.onNext(indexPath.row)
  }
}
