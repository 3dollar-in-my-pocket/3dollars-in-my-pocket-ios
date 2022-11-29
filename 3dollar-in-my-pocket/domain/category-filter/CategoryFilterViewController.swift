import UIKit

import RxDataSources
import ReactorKit

final class CategoryFilterViewController: BaseViewController, View, CategoryFilterCoordinator {
    private let categoryFilterView = CategoryFilterView()
    private let categoryFilterReactor: CategoryFilterReactor
    private weak var coordinator: CategoryFilterCoordinator?
    private var categoryDataSource:
    RxCollectionViewSectionedReloadDataSource<CategoryFilterSectionModel>!
    
    static func instance(storeType: StoreType) -> CategoryFilterViewController {
        return CategoryFilterViewController(storeType: storeType).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init(storeType: StoreType) {
        self.categoryFilterReactor = CategoryFilterReactor(
            storeType: storeType,
            advertisementService: AdvertisementService(),
            metaContext: MetaContext.shared,
            globalState: GlobalState.shared
        )
        
        super.init(nibName: nil, bundle: nil)
        self.setupDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.categoryFilterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.reactor = self.categoryFilterReactor
        self.coordinator = self
        self.categoryFilterReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.categoryFilterView.backgroundButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.categoryFilterReactor.openURLPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] url in
                self?.coordinator?.openURL(url: url)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.categoryFilterReactor.dismissPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.categoryFilterReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: CategoryFilterReactor) {
        // Bind Action
        self.categoryFilterView.categoryCollectionView.rx.itemSelected
            .map { Reactor.Action.tapCategory(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { [CategoryFilterSectionModel(categories: $0.categories)] }
            .asDriver(onErrorJustReturn: [])
            .drive(self.categoryFilterView.categoryCollectionView.rx.items(
                dataSource: self.categoryDataSource)
            )
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.categoryDataSource
        = .init(configureCell: { _, collectionView, indexPath, sectionModel in
            switch sectionModel {
            case .category(let category):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CategoryFilterCell.registerId,
                    for: indexPath
                ) as? CategoryFilterCell else { return BaseCollectionViewCell() }
                
                cell.bind(category: category)
                return cell
            }
        })
        
        self.categoryDataSource.configureSupplementaryView
        = { _, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: CategoryFilterHeaderView.registerID,
                    for: indexPath
                ) as? CategoryFilterHeaderView else {
                    return UICollectionReusableView()
                }
                
                headerView.rx.tap
                    .map { Reactor.Action.tapBanner }
                    .bind(to: self.categoryFilterReactor.action)
                    .disposed(by: headerView.disposeBag)
                
                self.categoryFilterReactor.state
                    .map { $0.advertisement }
                    .distinctUntilChanged()
                    .do(onNext: { advertisement in
                        if let layout = collectionView.collectionViewLayout
                            as? UICollectionViewFlowLayout {
                            layout.headerReferenceSize = advertisement == nil
                            ? .zero
                            : CategoryFilterHeaderView.size
                        }
                    })
                    .asDriver(onErrorJustReturn: nil)
                    .drive(headerView.rx.advertisement)
                    .disposed(by: headerView.disposeBag)
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}
