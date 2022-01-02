import UIKit
import RxSwift

final class MyPageViewController: BaseVC, MyPageCoordinator {
    private weak var coordinator: MyPageCoordinator?
    private let myPageView = MyPageView()
    private let viewModel = MyPageViewModel(
        userService: UserService(),
        visitHistoryService: VisitHistoryService()
    )
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    static func instance() -> UINavigationController {
        let viewController = MyPageViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: R.image.ic_my(),
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
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.barTintColor = R.color.gray100()
    }
    
    override func bindEvent() {
        self.myPageView.settingButton.rx.tap
            .asDriver()
            .do(onNext: { _ in
                GA.shared.logEvent(event: .setting_button_clicked, page: .my_info_page)
            })
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToSetting()
            })
            .disposed(by: self.disposeBag)
        
        self.myPageView.storeCountButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToTotalRegisteredStore()
            })
            .disposed(by: self.disposeBag)
        
        self.myPageView.reviewCountButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToMyReview()
            })
            .disposed(by: self.disposeBag)
        
        self.myPageView.visitHistoryButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToMyVisitHistory()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelInput() {
        self.myPageView.refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.input.viewDidLoad)
            .disposed(by: self.disposeBag)
        
        self.myPageView.medalCountButton.rx.tap
            .bind(to: self.viewModel.input.tapMyMedal)
            .disposed(by: self.disposeBag)
        
        self.myPageView.medalImageButton.rx.tap
            .bind(to: self.viewModel.input.tapMyMedal)
            .disposed(by: self.disposeBag)
        
        self.myPageView.visitHistoryCollectionView.rx.itemSelected
            .map { $0.row }
            .bind(to: self.viewModel.input.tapVisitHistory)
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.user
            .asDriver(onErrorJustReturn: User())
            .drive(self.myPageView.rx.user)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.visitHistories
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] visitHistories in
                self?.myPageView.visitHistoryEmptyView.isHidden = !visitHistories.isEmpty
            })
            .drive(self.myPageView.visitHistoryCollectionView.rx.items(
                cellIdentifier: MyVisitHistoryCell.registerId,
                cellType: MyVisitHistoryCell.self
            )) { _, visitHistory, cell in
                cell.bind(visitHitory: visitHistory)
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.isRefreshing
            .asDriver(onErrorJustReturn: false)
            .drive(self.myPageView.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.goToMyMedal
            .asDriver(onErrorJustReturn: Medal())
            .drive(onNext: { [weak self] medal in
                self?.coordinator?.goToMyMedal(medal: medal)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.goToStoreDetail
            .asDriver(onErrorJustReturn: -1)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.goToStoreDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
    }
}

extension MyPageViewController: MyMedalViewControllerDelegate {
    func onChangeMedal(medal: Medal) {
        self.viewModel.input.onChangeMedal.onNext(medal)
    }
}
