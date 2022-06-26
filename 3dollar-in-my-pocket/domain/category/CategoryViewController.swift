import UIKit

import Base
import RxDataSources
import ReactorKit

final class CategoryViewController: BaseVC, View, CategoryCoordinator {
    private let categoryView = CategoryView()
    private let categoryReactor = CategoryReactor(
        categoryService: CategoryService(),
        advertisementService: AdvertisementService()
    )
    private weak var coordinator: CategoryCoordinator?
    private var categoryDataSource
        : RxCollectionViewSectionedReloadDataSource<SectionModel<Advertisement?, MenuCategory>>!
    
    static func instance() -> UINavigationController {
        let viewController = CategoryViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_category"),
                tag: TabBarTag.home.rawValue
            )
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.setNavigationBarHidden(true, animated: false)
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func loadView() {
        self.view = self.categoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDataSource()
        self.reactor = self.categoryReactor
        self.coordinator = self
        self.categoryReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.categoryReactor.pushCategoryListPublisher
            .asDriver(onErrorJustReturn: .BUNGEOPPANG)
            .drive(onNext: { [weak self] category in
                self?.coordinator?.pushCategoryList(category: category)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.categoryReactor.openURLPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] url in
                self?.coordinator?.openURL(url: url)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.categoryReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: CategoryReactor) {
        // Bind Action
        self.categoryView.categoryCollectionView.rx.itemSelected
            .map { Reactor.Action.tapCategory(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.categorySections }
            .asDriver(onErrorJustReturn: [])
            .drive(
                self.categoryView.categoryCollectionView.rx
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
                        .bind(to: self.categoryReactor.action)
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
