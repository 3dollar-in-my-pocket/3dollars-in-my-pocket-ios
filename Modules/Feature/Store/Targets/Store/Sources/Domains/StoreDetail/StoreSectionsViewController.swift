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
    private var displayedImpressionIdentifiers = Set<String>()
    /// 메뉴 더보기를 누른 INFO_V1 섹션. 셀 재사용 후에도 펼침을 유지하기 위해 컨트롤러가 보관한다.
    private var expandedMenuIdentifiers = Set<String>()
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
            StoreEditCell.self,
            StoreMarginCell.self,
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
        // 섹션 간 간격은 서버가 MARGIN 섹션으로 내려준다.
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
            .compactMap { ($0 as? StoreEditSection)?.map?.location }
            .first
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        onStoreInformationChanged?(title, location)

        let identifiers = sections.enumerated().map { "\($0.offset)-\($0.element.type.rawValue)" }
        let previousSectionsByIdentifier = sectionsByIdentifier
        sectionsByIdentifier = Dictionary(uniqueKeysWithValues: zip(identifiers, sections))
        displayedImpressionIdentifiers.removeAll()
        // 리뷰 작성 등으로 재조회해도 같은 섹션이면 메뉴 펼침 상태를 유지한다.
        expandedMenuIdentifiers.formIntersection(identifiers)

        // 섹션 구성이 그대로면 고정 탭 등록을 유지한다. 재조회마다 비우면 업데이트 중 탭이 원위치로
        // 돌아가고 컬렉션뷰가 그 셀을 기준으로 앵커링해 스크롤이 탭 위치로 튄다.
        if dataSource.snapshot().itemIdentifiers != identifiers {
            (collectionView.collectionViewLayout as? StickySectionLayout)?.clear()
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(identifiers)
        // 재조회 시 내용이 바뀐 섹션만 다시 그린다.
        // 전부 reconfigure 하면 estimated 높이가 초기화되어 스크롤 위치가 위로 튄다.
        let changedIdentifiers = identifiers.filter { identifier in
            guard let previous = previousSectionsByIdentifier[identifier],
                  let current = sectionsByIdentifier[identifier] else { return false }
            return AnyHashable(previous) != AnyHashable(current)
        }
        if changedIdentifiers.isEmpty.isNot {
            snapshot.reconfigureItems(changedIdentifiers)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// 접힌 메뉴를 펼친다. reconfigure 로 같은 셀을 다시 bind 해 셀프사이징 높이가 갱신되게 한다.
    private func expandMenu(identifier: String) {
        guard expandedMenuIdentifiers.insert(identifier).inserted else { return }

        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([identifier])
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
            case let section as StoreEditSection:
                let cell: StoreEditCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); cell.onAction = actionHandler; return cell
            case let section as StoreMarginSection:
                let cell: StoreMarginCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(section); return cell
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
                cell.bind(section, isMenuExpanded: self.expandedMenuIdentifiers.contains(identifier))
                cell.onAction = actionHandler
                cell.onToggleMenuExpansion = { [weak self] in self?.expandMenu(identifier: identifier) }
                return cell
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
        guard let index = identifiers.firstIndex(where: { sectionsByIdentifier[$0]?.type == sectionType }) else { return }
        let indexPath = IndexPath(item: index, section: 0)

        // 아직 표시되지 않은 셀은 estimated 높이라 목표 좌표가 부정확하다.
        // 한 번 이동해 주변 셀을 실측한 뒤 같은 계산을 반복하면 정확한 위치에 멈춘다.
        for _ in 0..<2 {
            guard let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return }

            // 상단에 고정된 탭 높이만큼 내려서 목표 섹션이 탭에 가려지지 않게 한다.
            let topInset = collectionView.adjustedContentInset.top
            let minY = -topInset
            let maxY = max(
                collectionView.contentSize.height + collectionView.adjustedContentInset.bottom - collectionView.bounds.height,
                minY
            )
            let targetY = attributes.frame.minY - topInset - StoreTabCell.Layout.height
            let offsetY = min(max(targetY, minY), maxY)
            collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            collectionView.layoutIfNeeded()
        }
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
