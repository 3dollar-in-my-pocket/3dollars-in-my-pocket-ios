import UIKit
import RxSwift

protocol MyPageDelegate: class {
  func onScrollStart()
  func onScrollEnd()
}

class MyPageVC: BaseVC {
  
  private lazy var myPageView = MyPageView(frame: self.view.frame)
  weak var delegate: MyPageDelegate?
  private var viewModel = MyPageViewModel()
  
  static func instance() -> MyPageVC {
    return MyPageVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = myPageView
    myPageView.scrollView.delegate = self
    setupRegisterCollectionView()
    setUpReviewTableView()
  }
  
  override func bindViewModel() {
    viewModel.reportedStores.bind(to: myPageView.registerCollectionView.rx.items(cellIdentifier: RegisterCell.registerId, cellType: RegisterCell.self)) { row, store, cell in
      cell.bind(store: store)
    }.disposed(by: disposeBag)
    
    viewModel.reportedReviews.bind(to: myPageView.reviewTableView.rx.items(cellIdentifier: MyPageReviewCell.registerId, cellType: MyPageReviewCell.self)) { row, review, cell in
      switch row {
      case 0:
        cell.setTopRadius()
        cell.setEvenBg()
      case 1:
        cell.setOddBg()
      case 2:
        cell.setEvenBg()
      default:
        break
      }
      
      if let count = try? self.viewModel.reportedReviews.value().count {
        if row == count - 1 {
          cell.setBottomRadius()
        }
      }
      cell.bind(review: review)
    }.disposed(by: disposeBag)
    
    myPageView.settingButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToSetting)
      .disposed(by: disposeBag)
    
    myPageView.registerTotalBtn.rx.tap.bind { [weak self] in
      self?.navigationController?.pushViewController(RegisteredVC.instance(), animated: true)
    }.disposed(by: disposeBag)
    
    myPageView.reviewTotalBtn.rx.tap.bind { [weak self] in
      self?.navigationController?.pushViewController(MyReviewVC.instance(), animated: true)
    }.disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getMyInfo()
    getReportedStore()
    getMyReviews()
  }
  
  private func setupRegisterCollectionView() {
    myPageView.registerCollectionView.delegate = self
    myPageView.registerCollectionView.register(RegisterCell.self, forCellWithReuseIdentifier: RegisterCell.registerId)
  }
  
  private func setUpReviewTableView() {
    myPageView.reviewTableView.delegate = self
    myPageView.reviewTableView.register(MyPageReviewCell.self, forCellReuseIdentifier: MyPageReviewCell.registerId)
  }
  
  private func goToSetting() {
    let settingVC = SettingVC.instance()
    
    self.navigationController?.pushViewController(settingVC, animated: true)
  }
  
  private func getMyInfo() {
    UserService().getUserInfo().subscribe(
      onNext: { [weak self] user in
        self?.myPageView.nicknameLabel.text = user.nickname
      },
      onError: { [weak self] error in
        if let httpError = error as? HTTPError {
          self?.showHTTPErrorAlert(error: httpError)
        }
      }).disposed(by: disposeBag)
  }
  
  private func getReportedStore() {
    StoreService().getReportedStore(page: 1)
      .subscribe(
        onNext: { [weak self] storePage in
          guard let self = self else { return }
          self.myPageView.setRegisterEmpty(isEmpty: storePage.content.isEmpty, count: storePage.totalElements)
          if storePage.content.count > 5 {
            var sliceArray: [Store?] = Array(storePage.content[0...4])
            
            sliceArray.append(nil)
            self.viewModel.reportedStores.onNext(sliceArray)
          } else {
            self.viewModel.reportedStores.onNext(storePage.content)
          }
        }, onError: { [weak self] error in
          guard let self = self else { return }
          
          if let error = error as? HTTPError {
            self.showHTTPErrorAlert(error: error)
          }
        })
      .disposed(by: disposeBag)
  }
  
  private func getMyReviews() {
    ReviewService().getMyReview(page: 1)
      .subscribe(
        onNext: { [weak self] reviewPage in
          guard let self = self else { return }
          
          self.myPageView.setReviewEmpty(isEmpty: reviewPage.content.isEmpty, count: reviewPage.totalElements)
          if reviewPage.totalElements > 3 {
            self.viewModel.reportedReviews.onNext(Array(reviewPage.content[0...2]))
          } else {
            var contents: [Review?] = reviewPage.content
            
            while contents.count != 3 {
              contents.append(nil)
            }
            self.viewModel.reportedReviews.onNext(contents)
          }
          
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          
          if let httpError = error as? HTTPError {
            self.showHTTPErrorAlert(error: httpError)
          }
        })
      .disposed(by: disposeBag)
  }
}

extension MyPageVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 172, height: 172)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let store = try? self.viewModel.reportedStores.value()[indexPath.row] {
      self.navigationController?.pushViewController(DetailVC.instance(storeId: store.id), animated: true)
    } else {
      self.navigationController?.pushViewController(RegisteredVC.instance(), animated: true)
    }
  }
}

extension MyPageVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let store = try? self.viewModel.reportedReviews.value()[indexPath.row] {
      self.navigationController?.pushViewController(DetailVC.instance(storeId: store.storeId), animated: true)
    }
  }
}

extension MyPageVC: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.delegate?.onScrollStart()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.delegate?.onScrollEnd()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.delegate?.onScrollEnd()
  }
}
