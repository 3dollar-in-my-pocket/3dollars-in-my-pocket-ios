import UIKit
import MapKit

import Common
import DesignSystem
import Model
import Log
import WriteInterface

final class StoreDetailViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }

    private let storeDetailView = StoreDetailView()
    private let viewModel: StoreDetailViewModel
    private lazy var datasource = StoreDetailDatasource(
        collectionView: storeDetailView.collectionView,
        viewModel: viewModel,
        rootViewController: self
    )
    fileprivate var modalDismissWorkItems: [ObjectIdentifier: DispatchWorkItem] = [:]

    static func instance(storeId: Int) -> StoreDetailViewController {
        return StoreDetailViewController(storeId: storeId)
    }

    init(storeId: Int) {
        self.viewModel = StoreDetailViewModel(storeId: storeId)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = storeDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.load.send(())

        storeDetailView.collectionView.collectionViewLayout = createLayout()
        setupOutsideModalTapGesture()
    }

    private func setupOutsideModalTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideModalTap(_:)))
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        storeDetailView.addGestureRecognizer(gesture)
    }

    @objc private func handleOutsideModalTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: storeDetailView)
        for case let modal as DismissibleStoreDetailModal in storeDetailView.subviews where !modal.frame.contains(location) {
            animateModalOut(view: modal)
        }
    }

    override func sendPageView() {
        viewModel.input.didAppear.send(())
    }

    override func bindEvent() {
        storeDetailView.backButton
            .controlPublisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }

    override func bindViewModelInput() {
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

    override func bindViewModelOutput() {
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

                case .pushEditStore(let viewModel):
                    owner.pushEditStore(viewModel: viewModel)
                case .navigateAppleMap(let location):
                    owner.navigateAppleMap(location: location)
                case .pushWebView(let webViewType):
                    owner.pushWebView(webViewType: webViewType)
                case .pushStoreDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                case .presentContributors(let viewModel):
                    owner.presentContributors(viewModel: viewModel)
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

        viewModel.output.showDisappearanceInquiryModal
            .main
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, context) in
                owner.showDisappearanceInquiryModal(with: context)
            }
            .store(in: &cancellables)

        viewModel.output.showVisitCertificationInducementModal
            .main
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, context) in
                owner.showVisitCertificationInducementModal(with: context)
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
            case .verifiedBanner:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreDetailVerifiedBannerCell.Layout.height)
                ))

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailVerifiedBannerCell.Layout.height)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 16, trailing: 20)

                return section

            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreDetailOverviewCell.Layout.storeDetailHeight)
                ))

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailOverviewCell.Layout.storeDetailHeight)
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
                section.contentInsets = .init(top: 0, leading: 20, bottom: 16, trailing: 20)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(36)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]

                return section
                
            case .divider:
                let items = sectionIdentifier.items.map { sectionItem -> NSCollectionLayoutItem in
                    let itemHeight: CGFloat
                    if case .divider(let configuration) = sectionItem {
                        itemHeight = configuration.height
                    } else {
                        itemHeight = StoreDetailDividerCell.Layout.defaultHeight
                    }
                    
                    return NSCollectionLayoutItem(layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(itemHeight)
                    ))
                }
                
                let totalHeight = sectionIdentifier.items.reduce(0) { total, sectionItem in
                    if case .divider(let configuration) = sectionItem {
                        return total + configuration.height
                    } else {
                        return total + StoreDetailDividerCell.Layout.defaultHeight
                    }
                }
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(totalHeight)
                    ),
                    subitems: items
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                
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
                section.contentInsets = .init(top: 0, leading: 20, bottom: 16, trailing: 20)
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
                    )
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
                section.contentInsets = .init(top: 12, leading: 20, bottom: 16, trailing: 20)
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(24)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .topLeading
                )]

                return section

            case .bossStoreAppIntro:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StoreDetailBossStoreAppIntroCell.Layout.height)
                ))

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(StoreDetailBossStoreAppIntroCell.Layout.height)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
                return section
                
            case .bridgeCarousel:
                let bridgeCarouselViewModel = sectionIdentifier.items.first?.bridgeCarouselViewModel
                let height = StoreBridgeCarouselCell.Layout.height()
                
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
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
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
        let appleAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.appleMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.apple)
        }
        let cancelAction = UIAlertAction(title: Strings.NavigationBottomSheet.Action.cancel, style: .cancel)

        alertController.addAction(naverAction)
        alertController.addAction(kakaoAction)
        alertController.addAction(appleAction)
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

    private func presentContributors(viewModel: ContributorsViewModel) {
        let viewController = ContributorsViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen

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

    private func pushEditStore(viewModel: EditStoreViewModelInterface) {
        let viewController = Environment.writeInterface.createEditStoreViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func navigateAppleMap(location: LocationResponse) {
        let latitude: CLLocationDegrees = location.latitude
        let longitude: CLLocationDegrees = location.longitude
        let destinationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: destinationCoordinate)
        let mapItem = MKMapItem(placemark: placemark)

        mapItem.name = "목적지"

        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,  // 운전 모드
            MKLaunchOptionsShowsTrafficKey: true  // 교통 상황 표시
        ] as [String: Any]

        mapItem.openInMaps(launchOptions: options)
    }

    private func pushWebView(webViewType: WebViewType) {
        let viewController = Environment.appModuleInterface.createWebViewController(webviewType: webViewType)

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)

        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Display Item Modal
extension StoreDetailViewController {
    func showDisappearanceInquiryModal(with context: StoreDetailModalContext<StoreDetailDisappearanceInquiryModalViewModel>) {
        let view = StoreDetailDisappearanceInquiryModalView()
        view.bind(viewModel: context.viewModel)
        storeDetailView.addSubview(view)
        storeDetailView.collectionView.contentInset.bottom = 360
        view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(storeDetailView.bottomStickyView.snp.top).offset(-20)
        }

        context.viewModel.output.onReportSucceed
            .main
            .sink { [weak self, weak view] in
                let icon = Icons.heartFill.image.withTintColor(Colors.mainRed.color, renderingMode: .alwaysOriginal)
                ToastManager.shared.show(message: Strings.DisplayItemModal.thanksToast, icon: icon)
                if let view {
                    self?.animateModalOut(view: view)
                }
            }
            .store(in: &context.viewModel.cancellables)

        context.viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &context.viewModel.cancellables)

        context.viewModel.input.didTapReport
            .main
            .sink { [weak self, weak view] in
                guard let self, let view else { return }
                self.cancelAutoDismiss(view: view)
            }
            .store(in: &context.viewModel.cancellables)

        if let duration = context.trigger?.displayDurationSeconds {
            context.viewModel.output.selectedIndex
                .compactMap { $0 }
                .main
                .sink { [weak self, weak view] _ in
                    guard let self, let view else { return }
                    self.scheduleAutoDismiss(view: view, duration: duration)
                }
                .store(in: &context.viewModel.cancellables)
        }

        animateModalIn(view: view, trigger: context.trigger, onDisplayed: context.onDisplayed)
    }

    func showVisitCertificationInducementModal(with context: StoreDetailModalContext<StoreDetailVisitInducementModalViewModel>) {
        let view = StoreDetailVisitInducementModalView()
        view.bind(viewModel: context.viewModel)
        storeDetailView.addSubview(view)
        view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(storeDetailView.bottomStickyView.snp.top).offset(-20)
        }

        context.viewModel.output.onSuccessVisit
            .main
            .sink { [weak self, weak view] (message: String) in
                let icon = Icons.heartFill.image.withTintColor(Colors.mainRed.color, renderingMode: .alwaysOriginal)
                ToastManager.shared.show(message: message, icon: icon)
                if let view {
                    self?.animateModalOut(view: view)
                }
                self?.viewModel.input.load.send(())
            }
            .store(in: &context.viewModel.cancellables)

        context.viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: StoreDetailViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &context.viewModel.cancellables)

        animateModalIn(view: view, trigger: context.trigger, onDisplayed: context.onDisplayed)
    }

    private func animateModalIn(view: UIView, trigger: StoreDisplayTrigger?, onDisplayed: @escaping () -> Void) {
        view.superview?.layoutIfNeeded()
        let translationY = max(view.bounds.height + 40, 240)
        view.transform = CGAffineTransform(translationX: 0, y: translationY)
        view.alpha = 0

        let delay = trigger?.displayAfterSeconds ?? 0
        let duration = trigger?.displayDurationSeconds

        UIView.animate(
            withDuration: 0.5,
            delay: delay,
            options: [.curveEaseInOut]
        ) {
            view.transform = .identity
            view.alpha = 1
        } completion: { [weak self, weak view] _ in
            guard let self, let view, view.superview != nil else { return }
            onDisplayed()

            if let duration {
                self.scheduleAutoDismiss(view: view, duration: duration)
            }
        }
    }

    fileprivate func animateModalOut(view: UIView) {
        cancelAutoDismiss(view: view)
        let translationY = max(view.bounds.height + 40, 240)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            view.transform = CGAffineTransform(translationX: 0, y: translationY)
            view.alpha = 0
        } completion: { _ in
            view.removeFromSuperview()
        }
    }

    fileprivate func scheduleAutoDismiss(view: UIView, duration: Double) {
        cancelAutoDismiss(view: view)
        let id = ObjectIdentifier(view)
        let workItem = DispatchWorkItem { [weak self, weak view] in
            guard let self, let view, view.superview != nil else { return }
            self.modalDismissWorkItems[id] = nil
            self.animateModalOut(view: view)
        }
        modalDismissWorkItems[id] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    fileprivate func cancelAutoDismiss(view: UIView) {
        let id = ObjectIdentifier(view)
        modalDismissWorkItems[id]?.cancel()
        modalDismissWorkItems[id] = nil
    }
}
