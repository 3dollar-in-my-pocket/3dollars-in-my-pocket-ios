import UIKit

import ReactorKit
import RxDataSources

final class BossStoreDetailViewController:
    BaseViewController,
    View,
    BossStoreDetailCoordinator {
    private let bossStoreDetailView = BossStoreDetailView()
    private let bossStoreDetailReactor: BossStoreDetailReactor
    private weak var coordinator: BossStoreDetailCoordinator?
    private var bossStoreCollectionViewDataSource
    : RxCollectionViewSectionedReloadDataSource<BossStoreSectionModel>!
    
    init(storeId: String) {
        self.bossStoreDetailReactor = BossStoreDetailReactor(
            storeId: storeId,
            storeService: StoreService(),
            bookmarkService: BookmarkService(),
            locationManaber: LocationManager.shared,
            globalState: GlobalState.shared,
            userDefaults: UserDefaultsUtil(),
            gaManager: GAManager.shared
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(storeId: String) -> BossStoreDetailViewController {
        return BossStoreDetailViewController(storeId: storeId).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.bossStoreDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDataSource()
        self.coordinator = self
        self.reactor = self.bossStoreDetailReactor
        self.bossStoreDetailReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.bossStoreDetailView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bossStoreDetailReactor.pushFeedbackPublisher
            .asDriver(onErrorJustReturn: "" )
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.pushFeedback(storeId: storeId)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bossStoreDetailReactor.pushSharePublisher
            .asDriver(onErrorJustReturn: BossStore())
            .drive(onNext: { [weak self] store in
                self?.coordinator?.shareToKakao(store: store)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bossStoreDetailReactor.pushURLPublisher
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] url in
                self?.coordinator?.pushURL(url: url)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bossStoreDetailReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bossStoreDetailReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: BossStoreDetailReactor) {
        // Bind acion
        self.bossStoreDetailView.feedbackButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapFeedback }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind state
        reactor.state
            .compactMap { $0.store.categories.first }
            .asDriver(onErrorJustReturn: FoodTruckCategory.totalCategory)
            .drive(self.bossStoreDetailView.rx.category)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.store.status == .open }
            .asDriver(onErrorJustReturn: false)
            .drive(self.bossStoreDetailView.rx.isStoreOpen)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { [
                BossStoreSectionModel(store: $0.store),
                BossStoreSectionModel(
                    snsUrl: $0.store.snsUrl,
                    introduction: $0.store.introduction,
                    imageUrl: $0.store.imageURL
                ),
                BossStoreSectionModel(menus: $0.store.menus, showTotalMenus: $0.showTotalMenus),
                BossStoreSectionModel(appearanceDays: $0.store.appearanceDays),
                BossStoreSectionModel(feedbacks: $0.store.feedbacks)
            ] }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.bossStoreDetailView.collectionView.rx.items(
                dataSource: self.bossStoreCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.bossStoreCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<BossStoreSectionModel>(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case .overview(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BossStoreOverviewCell.registerId,
                        for: indexPath
                    ) as? BossStoreOverviewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    cell.currentLocationButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapCurrentLocation}
                        .bind(to: self.bossStoreDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.shareButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapShare}
                        .bind(to: self.bossStoreDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    self.bossStoreDetailReactor.moveCameraPublisher
                        .observe(on: MainScheduler.instance)
                        .bind(onNext: { [weak cell] location in
                            cell?.moveCamera(location: location)
                        })
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .info(let snsUrl, let introduction, let imageUrl):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BossStoreInfoCell.registerId,
                        for: indexPath
                    ) as? BossStoreInfoCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(snsUrl: snsUrl, introduction: introduction, imageUrl: imageUrl)
                    cell.snsButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapSNSButton }
                        .bind(to: self.bossStoreDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .menu(let menu):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BossStoreMenuCell.registerId,
                        for: indexPath
                    ) as? BossStoreMenuCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(menu: menu)
                    return cell
                    
                case .moreMenu(let menus):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BossStoreMoreMenuCell.registerId,
                        for: indexPath
                    ) as? BossStoreMoreMenuCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(menus: menus)
                    cell.rx.tap
                        .map { Reactor.Action.showTotalMenus }
                        .debug()
                        .bind(to: self.bossStoreDetailReactor.action)
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .emptyMenu:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BossStoreEmptyMenuCell.registerId,
                        for: indexPath
                    ) as? BossStoreEmptyMenuCell else { return BaseCollectionViewCell() }
                    
                    return cell
                    
                case .appearanceDay(let appearanceDay):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BossStoreWorkdayCell.registerId,
                        for: indexPath
                    ) as? BossStoreWorkdayCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(appearanceDays: appearanceDay)
                    return cell
                    
                case .feedbacks(let feedbacks):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BossStoreFeedbacksCell.registerId,
                        for: indexPath
                    ) as? BossStoreFeedbacksCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(feedbacks: feedbacks)
                    return cell
                }
        })
        
        self.bossStoreCollectionViewDataSource.configureSupplementaryView
        = { _, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: BossStoreHeaderView.registerId,
                    for: indexPath
                ) as? BossStoreHeaderView else { return UICollectionReusableView() }
                
                if indexPath.section == 1 {
                    headerView.titleLabel.text
                    = R.string.localization.boss_store_store_info()
                    headerView.rightButton.isHidden = true
                } else if indexPath.section == 2 {
                    headerView.titleLabel.text
                    = R.string.localization.boss_store_menu_info()
                    headerView.rightButton.isHidden = true
                } else if indexPath.section == 3 {
                    headerView.titleLabel.text
                    = R.string.localization.boss_store_workday()
                    headerView.rightButton.isHidden = true
                } else {
                    headerView.titleLabel.text
                    = R.string.localization.boss_store_store_feedback()
                    headerView.rightButton.isHidden = false
                    headerView.rightButton.setTitle(
                        R.string.localization.boss_store_feedback(),
                        for: .normal
                    )
                    headerView.rightButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapFeedback }
                        .bind(to: self.bossStoreDetailReactor.action)
                        .disposed(by: headerView.disposeBag)
                }
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}
