import UIKit

import ReactorKit
import RxSwift
import RxDataSources

final class MyPageViewController: BaseViewController, View, MyPageCoordinator {
    private weak var coordinator: MyPageCoordinator?
    private let myPageView = MyPageView()
    private let myPageReactor = MyPageReactor(
        userService: UserService(),
        visitHistoryService: VisitHistoryService(),
        bookmarkService: BookmarkService(),
        globalState: GlobalState.shared
    )
    private var myPageCollectionViewDataSource:
    RxCollectionViewSectionedReloadDataSource<MyPageSectionModel>!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> UINavigationController {
        let viewController = MyPageViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: "tab_my".localized,
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
        
        self.setupDataSource()
        self.reactor = self.myPageReactor
        self.coordinator = self
        self.myPageReactor.action.onNext(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.barTintColor = Color.gray100
    }
    
    override func bindEvent() {
        self.myPageView.settingButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToSetting()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.myPageReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bind(reactor: MyPageReactor) {
        // Bind Action
        self.myPageView.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.myPageView.collectionView.rx.itemSelected
            .filter { MyPageSectionType(sectionIndex: $0.section) == .visitHistory }
            .map { Reactor.Action.tapVisitHistory(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.myPageView.collectionView.rx.itemSelected
            .filter { MyPageSectionType(sectionIndex: $0.section) == .bookmark }
            .map { Reactor.Action.tapBookmark(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { state in
                [
                    MyPageSectionModel(user: state.user),
                    MyPageSectionModel(visitHistories: state.visitHistories),
                    MyPageSectionModel(bookmarks: state.bookmarks)
                ]
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.myPageView.collectionView.rx.items(
                dataSource: self.myPageCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$endRefreshing)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.myPageView.refreshControl.endRefreshing()
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushStoreDetail)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: -1)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.goToStoreDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushFoodTruckDetail)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.pushFoodtruckDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushMyMedal)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: Medal())
            .drive(onNext: { [weak self] medal in
                self?.coordinator?.goToMyMedal(medal: medal)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushBookmarkList)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] userName in
                self?.coordinator?.pushBookmarkList(userName: userName)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.myPageCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case .overview(let user):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyPageOverviewCollectionViewCell.registerId,
                        for: indexPath
                    ) as? MyPageOverviewCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(user: user)
                    cell.medalImageButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapMyMedal }
                        .bind(to: self.myPageReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.medalCountButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapMyMedal }
                        .bind(to: self.myPageReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.reviewCountButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .asDriver(onErrorJustReturn: ())
                        .drive(onNext: { [weak self] in
                            self?.coordinator?.goToMyReview()
                        })
                        .disposed(by: cell.disposeBag)
                    cell.storeCountButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .asDriver(onErrorJustReturn: ())
                        .drive(onNext: { [weak self] in
                            self?.coordinator?.goToTotalRegisteredStore()
                        })
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .visitHistory(let visitHistory):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyPageVisitHistoryCollectionViewCell.registerId,
                        for: indexPath
                    ) as? MyPageVisitHistoryCollectionViewCell else {
                        return BaseCollectionViewCell()
                    }
                    
                    cell.bind(visitHitory: visitHistory)
                    return cell
                    
                case .bookmark(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyPageBookmarkCollectionViewCell.registerId,
                        for: indexPath
                    ) as? MyPageBookmarkCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    return cell
                }
        })
        
        self.myPageCollectionViewDataSource.configureSupplementaryView
        = { _, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: MyPageSectionHeaderView.registerId,
                    for: indexPath
                ) as? MyPageSectionHeaderView else { return UICollectionReusableView() }
                let sectionType = MyPageSectionType(sectionIndex: indexPath.section)
                
                switch sectionType {
                case .visitHistory:
                    headerView.rx.tapMoreButton
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .asDriver(onErrorJustReturn: ())
                        .drive(onNext: { [weak self] _ in
                            self?.coordinator?.goToMyVisitHistory()
                        })
                        .disposed(by: headerView.disposeBag)
                    
                case .bookmark:
                    headerView.rx.tapMoreButton
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapBookmarkMore }
                        .bind(to: self.myPageReactor.action)
                        .disposed(by: headerView.disposeBag)
                    
                case .unknown:
                    break
                }
                headerView.bind(type: sectionType)
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}
