import UIKit

import ReactorKit
import RxSwift
import RxDataSources

final class BookmarkListViewController:
    BaseViewController, View, BookmarkListCoordinator {
    private let bookmarkListView = BookmarkListView()
    private let bookmarkListReactor = BookmarkListReactor(
        bookmarkService: BookmarkService()
    )
    private weak var coordinator: BookmarkListCoordinator?
    private var bookmarkCollectionViewDataSource:
    RxCollectionViewSectionedReloadDataSource<BookmarkListSectionModel>!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> BookmarkListViewController {
        return BookmarkListViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.bookmarkListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDataSource()
        self.coordinator = self
        self.reactor = self.bookmarkListReactor
        self.bookmarkListReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.bookmarkListView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bookmarkListReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bookmarkListReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: BookmarkListReactor) {
        // Bind Action
        self.bookmarkListView.collectionView.rx.willDisplayCell
            .filter { BookmarkListSection(sectionIndex: $0.at.section) == .bookmarkStores }
            .map { BookmarkListReactor.Action.willDisplayCell(row: $0.at.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bookmarkListView.collectionView.rx.itemSelected
            .filter { BookmarkListSection(sectionIndex: $0.section) == .bookmarkStores }
            .map { Reactor.Action.tapStore(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { [
                BookmarkListSectionModel(overview: $0.bookmarkFolder),
                BookmarkListSectionModel(stores: $0.bookmarkFolder)
            ]}
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.bookmarkListView.collectionView.rx.items(
                dataSource: self.bookmarkCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.pushStoreDetail }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.pushStoreDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.pushFoodtruckDetail }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.pushFoodTruckDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.pushEditBookmarkFolder }
            .asDriver(onErrorJustReturn: BookmarkFolder())
            .drive(onNext: { [weak self] bookmarkFolder in
                
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.bookmarkCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<BookmarkListSectionModel>(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case .overview(let bookmarkFolder):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BookmarkOverviewCollectionViewCell.registerId,
                        for: indexPath
                    ) as? BookmarkOverviewCollectionViewCell else {
                        return BaseCollectionViewCell()
                    }
                    
                    cell.bind(bookmarkFolder: bookmarkFolder)
                    cell.editButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapEditOverview }
                        .bind(to: self.bookmarkListReactor.action)
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .bookmarkStore(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BookmarkStoreCollectionViewCell.registerId,
                        for: indexPath
                    ) as? BookmarkStoreCollectionViewCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    self.bookmarkListReactor.state
                        .map { $0.isDeleteMode }
                        .distinctUntilChanged()
                        .skip(1)
                        .asDriver(onErrorJustReturn: false)
                        .drive(cell.rx.isDeleteMode)
                        .disposed(by: cell.disposeBag)
                    return cell
                }
        })
        
        self.bookmarkCollectionViewDataSource.configureSupplementaryView
        = { _, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: BookmarkSectionHeaderView.registerId,
                    for: indexPath
                ) as? BookmarkSectionHeaderView else { return UICollectionReusableView() }
                
                headerView.deleteButton.rx.tap
                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                    .map { Reactor.Action.tapDeleteMode }
                    .bind(to: self.bookmarkListReactor.action)
                    .disposed(by: headerView.disposeBag)
                
                headerView.deleteAllButton.rx.tap
                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                    .map { Reactor.Action.tapDeleteAll }
                    .bind(to: self.bookmarkListReactor.action)
                    .disposed(by: headerView.disposeBag)
                
                headerView.finishButton.rx.tap
                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                    .map { Reactor.Action.tapFinish }
                    .bind(to: self.bookmarkListReactor.action)
                    .disposed(by: headerView.disposeBag)
                
                self.bookmarkListReactor.state
                    .compactMap { $0.totalCount }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: 0)
                    .drive(headerView.rx.totalCount)
                    .disposed(by: headerView.disposeBag)
                
                self.bookmarkListReactor.state
                    .map { $0.isDeleteMode }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: false)
                    .drive(headerView.rx.isDeleteMode)
                    .disposed(by: headerView.disposeBag)
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}
