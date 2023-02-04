import UIKit

import ReactorKit
import RxDataSources

final class BookmarkViewerViewController: BaseViewController, View, BookmarkViewerCoordinator {
    private let bookmarkViewerView = BookmarkViewerView()
    private let bookmarkViewerReactor: BookmarkViewerReactor
    private weak var coodinator: BookmarkViewerCoordinator?
    private var bookmarkViewerDataSource
    : RxCollectionViewSectionedReloadDataSource<BookmarkViewerSectionModel>!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(folderId: String) {
        self.bookmarkViewerReactor = BookmarkViewerReactor(
            folderId: folderId,
            bookmarkService: BookmarkService(),
            userDefaults: UserDefaultsUtil()
        )
        
        super.init(nibName: nil, bundle: nil)
        self.setupDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.bookmarkViewerView
    }
    
    static func instance(folderId: String) -> UINavigationController {
        let viewController = BookmarkViewerViewController(folderId: folderId)
        
        return UINavigationController(rootViewController: viewController).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.isNavigationBarHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coodinator = self
        self.reactor = self.bookmarkViewerReactor
        self.bookmarkViewerReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.bookmarkViewerView.closeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coodinator?.presenter.dismiss(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: BookmarkViewerReactor) {
        // Bind Action
        self.bookmarkViewerView.collectionView.rx.willDisplayCell
            .map { Reactor.Action.willDisplay(row: $0.at.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bookmarkViewerView.collectionView.rx.itemSelected
            .map { Reactor.Action.tapStore(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { [BookmarkViewerSectionModel(stores: $0.stores)] }
            .asDriver(onErrorJustReturn: [])
            .drive(self.bookmarkViewerView.collectionView.rx.items(
                dataSource: self.bookmarkViewerDataSource
            ))
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushStoreDetail)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] storeId in
                self?.coodinator?.pushStoreDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushFoodTruckDetail)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] storeId in
                self?.coodinator?.pushFoodTruckDetail(storeId: storeId)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$presentSigninDialog)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coodinator?.presentSigninDialog()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.bookmarkViewerDataSource
        = RxCollectionViewSectionedReloadDataSource<BookmarkViewerSectionModel>(
            configureCell: { _, collectionView, indexPath, store in
                let cell: BookmarkViewerStoreCollectionViewCell
                = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(store: store)
                return cell
        })
        
        self.bookmarkViewerDataSource.configureSupplementaryView
        = { _, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView: BookmarkViewerHeaderView
                = collectionView.dequeueReusableSupplementaryView(
                    ofkind: kind,
                    indexPath: indexPath
                )
                
                self.bookmarkViewerReactor.state
                    .map { $0.bookmarkTitle }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: "")
                    .drive(headerView.rx.title)
                    .disposed(by: headerView.disposeBag)
                
                self.bookmarkViewerReactor.state
                    .map { $0.bookmarkDescription }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: "")
                    .drive(headerView.rx.description)
                    .disposed(by: headerView.disposeBag)
                
                self.bookmarkViewerReactor.state
                    .map { $0.user }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: User())
                    .drive(headerView.rx.user)
                    .disposed(by: headerView.disposeBag)
                
                self.bookmarkViewerReactor.state
                    .map { $0.totalCount }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: 0)
                    .drive(headerView.rx.totalCount)
                    .disposed(by: headerView.disposeBag)
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}
