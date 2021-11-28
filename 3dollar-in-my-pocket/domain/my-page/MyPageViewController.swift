import UIKit
import RxSwift

final class MyPageViewController: BaseVC, MyPageCoordinator {
    private weak var coordinator: MyPageCoordinator?
    private let myPageView = MyPageView()
    private let viewModel = MyPageViewModel(
        userService: UserService(),
        storeService: StoreService(),
        reviewService: ReviewService()
    )
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    static func instance() -> UINavigationController {
        let viewController = MyPageViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_my"),
                tag: TabBarTag.my.rawValue
            )
        }
        return UINavigationController(rootViewController: viewController).then {
            $0.setNavigationBarHidden(true, animated: false)
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func loadView() {
        self.view = self.myPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.setupRegisterCollectionView()
        self.setUpReviewTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.barTintColor = R.color.gray100()
        self.viewModel.fetchMyInfo()
        self.viewModel.fetchReportedStore()
        self.viewModel.fetchMyReview()
    }
    
    override func bindViewModel() {
        // Bind output
//        self.viewModel.output.user
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: self.myPageView.bind(user:))
//            .disposed(by: disposeBag)
//
//        self.viewModel.output.registeredStoreCount
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: self.myPageView.setStore(count:))
//            .disposed(by: disposeBag)
//
//        self.viewModel.output.registeredStores
//            .bind(to: self.myPageView.registerCollectionView.rx.items(
//                cellIdentifier: RegisterCell.registerId,
//                cellType: RegisterCell.self
//            )) { row, store, cell in
//                cell.bind(store: store)
//            }
//            .disposed(by: disposeBag)
//
//        self.viewModel.output.reviewCount
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: self.myPageView.setReview(count:))
//            .disposed(by: disposeBag)
//
//        self.viewModel.output.reviews
//            .bind(to: self.myPageView.reviewTableView.rx.items(
//                cellIdentifier: MyPageReviewCell.registerId,
//                cellType: MyPageReviewCell.self
//            )) { row, review, cell in
//                switch row {
//                case 0:
//                    cell.setTopRadius()
//                    cell.setEvenBg()
//                case 1:
//                    cell.setOddBg()
//                case 2:
//                    cell.setEvenBg()
//                default:
//                    break
//                }
//
//                if row == self.myPageView.reviewTableView.numberOfRows(inSection: 0) - 1 {
//                    cell.setBottomRadius()
//                }
//                cell.bind(review: review)
//            }
//            .disposed(by: disposeBag)
//
//        self.viewModel.output.goToStoreDetail
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: { [weak self] storeId in
//                self?.coordinator?.goToStoreDetail(storeId: storeId)
//            })
//            .disposed(by: disposeBag)
//
//        self.viewModel.output.goToRegistered
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: { [weak self] in
//                self?.coordinator?.goToTotalRegisteredStore()
//            })
//            .disposed(by: disposeBag)
//
//        self.viewModel.httpErrorAlert
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: self.showHTTPErrorAlert(error:))
//            .disposed(by: disposeBag)
//
//        self.viewModel.output.showSystemAlert
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: self.showSystemAlert(alert:))
//            .disposed(by: disposeBag)
    }
    
    override func bindEvent() {
        self.myPageView.settingButton.rx.tap
            .observeOn(MainScheduler.instance)
            .do(onNext: { _ in
                GA.shared.logEvent(event: .setting_button_clicked, page: .my_info_page)
            })
            .bind(onNext: { [weak self] in
                self?.coordinator?.goToSetting()
            })
            .disposed(by: disposeBag)
        
//        self.myPageView.registerTotalButton.rx.tap
//            .do(onNext: { _ in
//                GA.shared.logEvent(event: .show_all_my_store_button_clicked, page: .my_info_page)
//            })
//            .bind(onNext: { [weak self] in
//                self?.coordinator?.goToTotalRegisteredStore()
//            })
//            .disposed(by: disposeBag)
//
//        self.myPageView.reviewTotalButton.rx.tap
//            .do(onNext: { _ in
//                GA.shared.logEvent(event: .show_all_my_review_button_clicked, page: .my_info_page)
//            })
//            .bind(onNext: { [weak self] in
//                self?.coordinator?.goToMyReview()
//            })
//            .disposed(by: disposeBag)
    }
    
    private func setupRegisterCollectionView() {
//        self.myPageView.registerCollectionView.register(
//            RegisterCell.self,
//            forCellWithReuseIdentifier: RegisterCell.registerId
//        )
//
//        self.myPageView.registerCollectionView.rx.itemSelected
//            .map { $0.row }
//            .bind(to: self.viewModel.input.tapStore)
//            .disposed(by: disposeBag)
    }
    
    private func setUpReviewTableView() {
//        self.myPageView.reviewTableView.register(
//            MyPageReviewCell.self,
//            forCellReuseIdentifier: MyPageReviewCell.registerId
//        )
//        
//        self.myPageView.reviewTableView.rx.itemSelected
//            .map { $0.row }
//            .bind(to: self.viewModel.input.tapReview)
//            .disposed(by: disposeBag)
    }
}
