import UIKit

import Common
import DesignSystem
import Model

public final class StoreDetailViewController: BaseViewController {
    private let storeDetailView = StoreDetailView()
    private let viewModel: StoreDetailViewModel
    private lazy var datasource = StoreDetailDatasource(
        collectionView: storeDetailView.collectionView,
        viewModel: viewModel,
        rootViewController: self
    )
    
    public static func instance(storeId: Int) -> StoreDetailViewController {
        return StoreDetailViewController(storeId: storeId)
    }
    
    public init(storeId: Int) {
        self.viewModel = StoreDetailViewModel(storeId: storeId)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = storeDetailView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.load.send(())
        
        storeDetailView.collectionView.collectionViewLayout = createLayout()
    }
    
    public override func bindEvent() {
        storeDetailView.backButton
            .controlPublisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    public override func bindViewModelInput() {
        storeDetailView.reportnButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReport)
            .store(in: &cancellables)
        
        storeDetailView.bottomStickyView.saveButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
        
        storeDetailView.bottomStickyView.visitButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapVisit)
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.sections
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, sections: [StoreDetailSection]) in
                owner.datasource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .receive(on: DispatchQueue.main)
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.isFavorited
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, isSaved: Bool) in
                owner.storeDetailView.bottomStickyView.setSaved(isSaved)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, route) in
                switch route {
                case .dismissReportModalAndPop:
                    owner.dismissReportModalAndPop()
                    
                case .presentReport(let viewModel):
                    owner.presentReport(viewModel: viewModel)
                    
                case .presentNavigation:
                    owner.presentNavigationModal()
                    
                case .presentWriteReview(let viewModel):
                    owner.presentWriteReviewBottomSheet(viewModel)
                    
                case .presentMapDetail(let viewModel):
                    owner.presentMapDetail(viewModel)
                    
                case .presentUploadPhoto(let viewModel):
                    owner.presentUploadPhoto(viewModel)
                    
                case .pushPhotoList(let viewModel):
                    owner.pushPhotoList(viewModel)
                    
                case .presentPhotoDetail(let viewModel):
                    owner.presentPhotoDetail(viewModel)
                    
                case .pushReviewList(let viewModel):
                    owner.pushReviewList(viewModel)
                    
                case .presentReportBottomSheetReview(let viewModel):
                    owner.presentReportReviewBottomSheet(viewModel)
                    
                case .presentVisit(let viewModel):
                    owner.presentVisit(viewModel)
                    
                case .pushEditStore(let storeId, let storeDetailData):
                    owner.pushEditStore(storeId: storeId, storeDetailData: storeDetailData)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.error
            .main
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self,
                  let sectionIdentifier = datasource.sectionIdentifier(section: sectionIndex) else {
                return .init(group: .init(layoutSize: .init(
                    widthDimension: .absolute(0),
                    heightDimension: .absolute(0)
                )))
            }
            
            switch sectionIdentifier.type {
            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreDetailOverviewCell.Layout.height)
                ))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailOverviewCell.Layout.height)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                return section
                
            case .visit:
                let height = StoreDetailVisitCell.Layout.calculateHeight(historyCount: sectionIdentifier.items.first?.historyContentsCount ?? 0)
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                ))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(height)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 32, trailing: 20)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(36)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
                
            case .info:
                let infoItemHeight = StoreDetailInfoCell.Layout.height
                let infoItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(infoItemHeight)
                ))
                
                let menuCellViewModel = sectionIdentifier.items.last?.menuCellViewModel
                let menuItemHeight = StoreDetailMenuCell.Layout.calculateHeight(
                    menus: menuCellViewModel?.output.menus ?? [],
                    isShowAll: menuCellViewModel?.output.isShowAll ?? false
                )
                let menuItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(menuItemHeight)
                ))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(infoItemHeight + menuItemHeight)
                    ),
                    subitems: [infoItem, menuItem]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 32, trailing: 20)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
                
            case .photo(let totalCount):
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .absolute(StoreDetailPhotoCell.Layout.size.width),
                    heightDimension: .absolute(StoreDetailPhotoCell.Layout.size.height)
                ))
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailPhotoCell.Layout.size.height)
                    ),
                    subitems: [item]
                )
                group.interItemSpacing = NSCollectionLayoutSpacing.fixed(StoreDetailPhotoCell.Layout.space)  
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 12, leading: 20, bottom: 32, trailing: 20)
                section.boundarySupplementaryItems = [
                    .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(24)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .topLeading
                    ),
                    .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(totalCount > 0 ? 0.1 : StoreDetailPhotoFooterView.Layout.height)
                        ),
                        elementKind: UICollectionView.elementKindSectionFooter,
                        alignment: .bottom,
                        absoluteOffset: CGPoint(x: 0, y: -32)
                    ),
                ]
                
                return section
                
            case .review:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(StoreDetailReviewCell.Layout.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(StoreDetailReviewCell.Layout.estimatedHeight)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.contentInsets = .init(top: 12, leading: 20, bottom: 32, trailing: 20)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(24)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]
                
                return section
            }
        }
        
        return layout
    }
    
    private func presentReport(viewModel: ReportBottomSheetViewModel) {
        let viewController = ReportBottomSheetViewController.instance(viewModel: viewModel)
        
        presentPanModal(viewController)
    }
    
    private func dismissReportModalAndPop() {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func presentNavigationModal() {
        let alertController = UIAlertController(
            title: Strings.NavigationBottomSheet.title,
            message: Strings.NavigationBottomSheet.message,
            preferredStyle: .actionSheet
        )
        let naverAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.naverMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.naver)
        }
        let kakaoAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.kakaoMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.kakao)
        }
        let cancelAction = UIAlertAction(title: Strings.NavigationBottomSheet.Action.cancel, style: .cancel)
        
        alertController.addAction(naverAction)
        alertController.addAction(kakaoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func presentWriteReviewBottomSheet(_ viewModel: ReviewBottomSheetViewModel) {
        let viewController = ReviewBottomSheetViewController.instance(viewModel: viewModel)
        
        presentPanModal(viewController)
    }
    
    private func presentMapDetail(_ viewModel: MapDetailViewModel) {
        let viewController = MapDetailViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
    
    private func presentUploadPhoto(_ viewModel: UploadPhotoViewModel) {
        let viewController = UploadPhotoViewController.instance(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
    
    private func pushPhotoList(_ viewModel: PhotoListViewModel) {
        let viewController = PhotoListViewController.instance(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentPhotoDetail(_ viewModel: PhotoDetailViewModel) {
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
    
    private func pushReviewList(_ viewModel: ReviewListViewModel) {
        let viewController = ReviewListViewControlelr.instance(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentReportReviewBottomSheet(_ viewModel: ReportReviewBottomSheetViewModel) {
        let viewController = ReportReviewBottomSheetViewController.instance(viewModel: viewModel)
        
        presentPanModal(viewController)
    }
    
    private func presentVisit(_ viewModel: VisitViewModel) {
        let viewController = VisitViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
    
    private func pushEditStore(storeId: Int, storeDetailData: StoreDetailData) {
        let viewController = Environment.writeInterface.getEditDetailViewController(
            storeId: storeId,
            storeDetailData: storeDetailData) { [weak self] _ in
                self?.viewModel.input.load.send(())
            }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
