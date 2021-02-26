import UIKit
import RxSwift

class MyPageVC: BaseVC {
  
  private lazy var myPageView = MyPageView(frame: self.view.frame)
  private let viewModel = MyPageViewModel(
    userService: UserService(),
    storeService: StoreService(),
    reviewService: ReviewService()
  )
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  
  static func instance() -> UINavigationController {
    let myPageVC = MyPageVC(nibName: nil, bundle: nil).then {
      $0.tabBarItem = UITabBarItem(
        title: nil,
        image: UIImage(named: "ic_my"),
        tag: TabBarTag.my.rawValue
      )
    }
    
    return UINavigationController(rootViewController: myPageVC).then {
      $0.setNavigationBarHidden(true, animated: false)
      $0.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view = myPageView
    self.setupRegisterCollectionView()
    self.setUpReviewTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.viewModel.fetchMyInfo()
    self.viewModel.fetchReportedStore()
    self.viewModel.fetchMyReview()
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.user
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.myPageView.bind(user:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.registeredStoreCount
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.myPageView.setStore(count:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.registeredStores
      .bind(to: self.myPageView.registerCollectionView.rx.items(
        cellIdentifier: RegisterCell.registerId,
        cellType: RegisterCell.self
      )) { row, store, cell in
        cell.bind(store: store)
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.reviewCount
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.myPageView.setReview(count:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.reviews
      .bind(to: self.myPageView.reviewTableView.rx.items(
              cellIdentifier: MyPageReviewCell.registerId,
              cellType: MyPageReviewCell.self
      )) { row, review, cell in
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
        // TODO: 제일 마지막 셀 radius 적용 필요
//        if let count = try? self.viewModel.reportedReviews.value().count {
//          if row == count - 1 {
//            cell.setBottomRadius()
//          }
//        }
        cell.bind(review: review)
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToStoreDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToStoreDetail(storeId:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.myPageView.settingButton.rx.tap
      .observeOn(MainScheduler.instance)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .setting_button_clicked, page: .my_info_page)
      })
      .bind(onNext: self.goToSetting)
      .disposed(by: disposeBag)
    
    self.myPageView.registerTotalButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .show_all_my_store_button_clicked, page: .my_info_page)
      })
      .bind(onNext: self.goToTotalRegisteredStore)
      .disposed(by: disposeBag)
    
    self.myPageView.reviewTotalButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .show_all_my_review_button_clicked, page: .my_info_page)
      })
      .bind(onNext: self.goToMyReview)
      .disposed(by: disposeBag)
  }
  
  private func setupRegisterCollectionView() {
    self.myPageView.registerCollectionView.register(
      RegisterCell.self,
      forCellWithReuseIdentifier: RegisterCell.registerId
    )
    
    self.myPageView.registerCollectionView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapStore)
      .disposed(by: disposeBag)
  }
  
  private func setUpReviewTableView() {
    self.myPageView.reviewTableView.register(
      MyPageReviewCell.self,
      forCellReuseIdentifier: MyPageReviewCell.registerId
    )
    
    self.myPageView.reviewTableView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapReview)
      .disposed(by: disposeBag)
  }
  
  private func goToSetting() {
    let settingVC = SettingVC.instance()
    
    self.navigationController?.pushViewController(settingVC, animated: true)
  }
  
  private func goToTotalRegisteredStore() {
    let registeredVC = RegisteredVC.instance()
    
    self.navigationController?.pushViewController(registeredVC, animated: true)
  }
  
  private func goToMyReview() {
    let myReviewVC = MyReviewVC.instance()
    
    self.navigationController?.pushViewController(myReviewVC, animated: true)
  }
  
  private func goToStoreDetail(storeId: Int) {
    let storeDetailVC = StoreDetailVC.instance(storeId: storeId)
    
    self.navigationController?.pushViewController(storeDetailVC, animated: true)
  }
}
