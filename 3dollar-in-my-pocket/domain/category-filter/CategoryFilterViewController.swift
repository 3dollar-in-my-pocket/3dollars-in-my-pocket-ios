import UIKit

import Base
import RxDataSources
import ReactorKit

final class CategoryFilterViewController: BaseViewController, View, CategoryFilterCoordinator {
    private let categoryFilterView = CategoryFilterView()
    private let categoryFilterReactor = CategoryFilterReactor(
        categoryService: CategoryService(),
        advertisementService: AdvertisementService()
    )
    private weak var coordinator: CategoryFilterCoordinator?
    private var categoryDataSource
        : RxCollectionViewSectionedReloadDataSource<SectionModel<Advertisement?, StreetFoodCategory>>!
    
    static func instance() -> CategoryFilterViewController {
        return CategoryFilterViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.categoryFilterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.setupDataSource()
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
            .map { $0.categorySections }
            .asDriver(onErrorJustReturn: [])
            .drive(
                self.categoryFilterView.categoryCollectionView.rx
                    .items(dataSource: self.categoryDataSource)
            )
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.categoryDataSource
            = .init(configureCell: { _, collectionView, indexPath, menuCategory in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CategoryCell.registerId,
                    for: indexPath
                ) as? CategoryCell else { return BaseCollectionViewCell() }
                
                cell.bind(menuCategory: menuCategory)
                return cell
            })
        
        self.categoryDataSource.configureSupplementaryView
            = { dataSource, collectionView, _, indexPath -> UICollectionReusableView in
                guard let adBannerHeaderView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: AdBannerHeaderView.registerID,
                    for: indexPath
                ) as? AdBannerHeaderView else {
                    return UICollectionReusableView()
                }
                
                if let advertisement = dataSource.sectionModels[indexPath.section].model {
                    adBannerHeaderView.bind(advertisement: advertisement)
                    adBannerHeaderView.rx.tap
                        .map { Reactor.Action.tapBanner }
                        .bind(to: self.categoryFilterReactor.action)
                        .disposed(by: adBannerHeaderView.disposeBag)
                } else {
                    if let layout
                        = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        layout.headerReferenceSize = .zero
                    }
                }
                
                return adBannerHeaderView
            }
    }
}
