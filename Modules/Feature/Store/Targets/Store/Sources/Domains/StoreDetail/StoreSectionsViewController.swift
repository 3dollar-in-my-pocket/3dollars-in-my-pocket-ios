import UIKit
import CoreLocation

import Common
import DesignSystem
import Model
import StoreInterface
import WriteInterface

/// Store v2 SDUI 응답을 순서대로 전용 셀에 렌더링하는, Home에 임베드 가능한 상세 컨테이너.
public final class StoreSectionsViewController: BaseViewController {
    /// Home 바텀시트의 상단 chrome이 상세 컨텐츠 스크롤에 맞춰 fade-in 하는 데 사용한다.
    public var onScrollOffsetChanged: ((CGFloat) -> Void)?
    /// 전체 화면 컨테이너가 상단 네비게이션 타이틀과 공유 정보를 구성하는 데 사용한다.
    public var onStoreInformationChanged: ((SDText?, CLLocationCoordinate2D?) -> Void)?

    private let viewModel: StoreSectionsViewModel
    private let collectionView: UICollectionView
    private var sectionsByIdentifier: [String: any StoreSectionComponent] = [:]
    private var editSection: StoreEditSection?
    private var displayedImpressionIdentifiers = Set<String>()
    private lazy var dataSource = makeDataSource()

    init(viewModel: StoreSectionsViewModel) {
        self.viewModel = viewModel
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: Self.makeLayout()
        )
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(storeId: Int, latitude: Double, longitude: Double) {
        self.init(viewModel: StoreSectionsViewModel(config: .init(
            storeId: storeId,
            latitude: latitude,
            longitude: longitude
        )))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func loadView() {
        view = collectionView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.register([
            StoreCalloutCell.self,
            StoreScreenPreviewCell.self,
            StoreMapCell.self,
            StoreRelatedStoresV2Cell.self,
            StoreAdmobCell.self,
            StoreTabCell.self,
            StoreCouponCell.self,
            StoreVisitCell.self,
            StorePostCell.self,
            StoreImageCell.self,
            StoreAppearanceDayCell.self,
            StoreInfoV1Cell.self,
            StoreInfoV2Cell.self,
            StoreCTACell.self,
            StoreReviewCell.self
        ])
        viewModel.input.load.send(())
    }

    public override func bindViewModelInput() { }

    public override func bindViewModelOutput() {
        viewModel.output.sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.apply(sections)
            }
            .store(in: &cancellables)

        viewModel.output.toast
            .receive(on: DispatchQueue.main)
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)

        viewModel.output.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.showErrorAlert(error: $0) }
            .store(in: &cancellables)

        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handle(route: $0) }
            .store(in: &cancellables)
    }

    private static func makeLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(120)
        ))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(120)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        // 네비게이션 바 높이는 호스트(바텀시트/전체화면)가 컨테이너 제약으로 확보한다.
        // 여기서는 네비 아래 여백만 준다.
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0)
        return StickySectionLayout(section: section)
    }

    private func apply(_ sections: [any StoreSectionComponent]) {
        let title = sections
            .compactMap { ($0 as? StoreScreenPreviewSection)?.header.title }
            .first
        let location = sections
            .compactMap { ($0 as? StoreMapSection)?.location }
            .first
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        onStoreInformationChanged?(title, location)

        // 서버가 MAP/EDIT 를 한 섹션으로 합치기 전까지, EDIT 는 별도 셀 없이 MAP 셀 하단에 함께 그린다.
        editSection = sections.compactMap { $0 as? StoreEditSection }.first
        let visibleSections = sections.filter { ($0 is StoreEditSection).isNot }

        let identifiers = visibleSections.enumerated().map { "\($0.offset)-\($0.element.type.rawValue)" }
        sectionsByIdentifier = Dictionary(uniqueKeysWithValues: zip(identifiers, visibleSections))
        displayedImpressionIdentifiers.removeAll()

        (collectionView.collectionViewLayout as? StickySectionLayout)?.clear()

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(identifiers)
        if #available(iOS 15.0, *) {
            snapshot.reconfigureItems(identifiers)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
        UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, identifier in
            guard let self, let component = self.sectionsByIdentifier[identifier] else { return nil }
            let actionHandler: (StoreSectionAction) -> Void = { [weak self] in
                self?.viewModel.input.didSelectAction.send($0)
            }

            switch component {
            case let section as StoreCalloutSection:
                let cell: StoreCalloutCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreScreenPreviewSection:
                let cell: StoreScreenPreviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreMapSection:
                let cell: StoreMapCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section, editSection: self.editSection); cell.onAction = actionHandler; return cell
            case let section as StoreRelatedStoresSectionV2:
                let cell: StoreRelatedStoresV2Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreAdmobSection:
                let cell: StoreAdmobCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section, rootViewController: self); return cell
            case let section as StoreTabSection:
                let cell: StoreTabCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreCouponSection:
                let cell: StoreCouponCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreVisitSection:
                let cell: StoreVisitCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StorePostSection:
                let cell: StorePostCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreImageSection:
                let cell: StoreImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreAppearanceDaySection:
                let cell: StoreAppearanceDayCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreInfoV1Section:
                let cell: StoreInfoV1Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreInfoV2Section:
                let cell: StoreInfoV2Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreCTASection:
                let cell: StoreCTACell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreReviewSection:
                let cell: StoreReviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            default:
                return nil
            }
        }
    }
}

extension StoreSectionsViewController: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScrollOffsetChanged?(scrollView.contentOffset.y)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (collectionView.collectionViewLayout as? StickySectionLayout)?.registerIfNeeded(cell: cell, indexPath: indexPath)

        guard let identifier = dataSource.itemIdentifier(for: indexPath),
              displayedImpressionIdentifiers.insert(identifier).inserted,
              let component = sectionsByIdentifier[identifier] else { return }

        switch component {
        case let section as StoreRelatedStoresSectionV2:
            viewModel.sendImpressionLog(section.impressionLog)
        case let section as StoreAdmobSection:
            viewModel.sendImpressionLog(section.cards.first?.impressionLog)
        default:
            break
        }
    }
}

// MARK: Route
private extension StoreSectionsViewController {
    func handle(route: StoreSectionsViewModel.Route) {
        switch route {
        case .presentWriteReview(let viewModel):
            presentPanModal(ReviewBottomSheetViewController.instance(viewModel: viewModel))
        case .presentMapDetail(let viewModel):
            present(MapDetailViewController(viewModel: viewModel), animated: true)
        case .presentUploadPhoto(let viewModel):
            present(UploadPhotoViewController.instance(viewModel: viewModel), animated: true)
        case .presentPhotoDetail(let viewModel):
            present(PhotoDetailViewController(viewModel: viewModel), animated: true)
        case .pushReviewList(let viewModel):
            navigationController?.pushViewController(ReviewListViewControlelr.instance(viewModel: viewModel), animated: true)
        case .pushStoreDetail(let storeId):
            let location = Preference.shared.userCurrentLocation.coordinate
            let viewController = StoreDetailFullScreenViewController(
                storeId: storeId,
                latitude: location.latitude,
                longitude: location.longitude
            )
            navigationController?.pushViewController(viewController, animated: true)
        case .presentCouponList:
            present(CouponTabViewController(viewModel: CouponTabViewModel()), animated: true)
        case .presentStoreReport(let viewModel):
            presentPanModal(ReportBottomSheetViewController.instance(viewModel: viewModel))
        case .presentReviewReport(let viewModel):
            presentPanModal(ReportReviewBottomSheetViewController.instance(viewModel: viewModel))
        case .pushEditStore(let viewModel):
            let viewController = Environment.writeInterface.createEditStoreViewController(viewModel: viewModel)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        case .scrollToSection(let sectionType):
            scrollToSection(sectionType)
        }
    }

    func scrollToSection(_ sectionType: StoreSectionType) {
        let identifiers = dataSource.snapshot().itemIdentifiers
        guard let index = identifiers.firstIndex(where: { sectionsByIdentifier[$0]?.type == sectionType }),
              let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: index, section: 0))
        else { return }

        // 상단에 고정된 탭 높이만큼 내려서 목표 섹션이 탭에 가려지지 않게 한다.
        let topInset = collectionView.adjustedContentInset.top
        let minY = -topInset
        let maxY = max(
            collectionView.contentSize.height + collectionView.adjustedContentInset.bottom - collectionView.bounds.height,
            minY
        )
        let targetY = attributes.frame.minY - topInset - StoreTabCell.Layout.height
        let offsetY = min(max(targetY, minY), maxY)
        collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
}

// MARK: StoreSectionScrollable
extension StoreSectionsViewController: StoreSectionScrollable {
    public var scrollableStoreId: Int {
        viewModel.storeId
    }

    public func scrollToSection(fragment: String) {
        viewModel.input.scrollToSectionFragment.send(fragment)
    }
}
