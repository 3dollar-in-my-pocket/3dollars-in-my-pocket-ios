import UIKit

import Common
import DesignSystem
import Model
import StoreInterface

import SnapKit

/// 가게 상세 v2 섹션 셀을 모두 등록한 공용 컬렉션뷰.
/// 가게 상세(`StoreSectionsViewController`)와 홈 미리보기 시트가 각자 이 뷰를 하나씩 소유하고, 스타일로 셀 매핑·레이아웃만 달리한다.
final class StoreSectionsView: UIView {
    enum Style {
        /// 가게 상세. 스티키 탭·서버 MARGIN 섹션 간격을 쓰고, 애드몹은 펼친 뒤(`isDisplayed`)에만 보인다.
        case detail
        /// 홈 미리보기 시트(tip). PREVIEW 를 시트 디자인 셀로 그리고, 애드몹은 바로 보이며 로드 실패 시 영역을 없앤다.
        case preview
    }

    private enum PreviewLayout {
        static let topInset: CGFloat = 16
        static let bottomInset: CGFloat = 4
        static let sectionSpacing: CGFloat = 16
    }

    let style: Style
    let collectionView: UICollectionView
    weak var rootViewController: UIViewController?

    var onAction: ((StoreSectionAction) -> Void)?
    var onTapImageGallery: (([SDImage], Int) -> Void)?
    var onClickAd: ((SDClickLog?) -> Void)?
    var onTapThreadPostLink: ((URL, SDClickLog?) -> Void)?
    var onImpression: ((SDImpressionLog?) -> Void)?
    var onScroll: ((UIScrollView) -> Void)?
    var onEvent: ((StorePreviewSectionsEvent) -> Void)?
    var onContentHeightChanged: ((CGFloat) -> Void)?

    /// 펼친 뒤(노출 확정)에만 애드몹 배너·쓰레드 임베드를 보이고 노출 로그를 보낸다. 미리보기 스타일은 항상 true.
    private(set) var isDisplayed: Bool
    var selectedTabIndex = 0

    private(set) var sections: [any StoreSectionComponent] = []
    private var identifiers: [String] = []
    private var sectionsByIdentifier: [String: any StoreSectionComponent] = [:]
    private var failedAdmobIdentifiers = Set<String>()
    private var displayedImpressionIdentifiers = Set<String>()
    private var expandedMenuIdentifiers = Set<String>()
    private var expandedPostCardIds = Set<String>()
    private var threadPostHeights: [[String]: CGFloat] = [:]
    private var isFavorited = false
    private var lastReportedContentHeight: CGFloat?
    private var contentSizeObservation: NSKeyValueObservation?
    private lazy var dataSource = makeDataSource()

    init(style: Style) {
        self.style = style
        self.isDisplayed = style == .preview
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout(style: style))
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register([
            StoreCalloutCell.self,
            StoreScreenPreviewCell.self,
            StorePreviewSheetCell.self,
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
            StoreReviewCell.self,
            StoreSkeletonCell.self,
            StoreThreadPostCell.self,
            StoreAdCell.self
        ])

        switch style {
        case .detail:
            collectionView.alwaysBounceVertical = true
        case .preview:
            // tip 높이는 컨텐츠에 맞춰 시트가 정하므로 내부 스크롤은 막는다.
            collectionView.isScrollEnabled = false
            contentSizeObservation = collectionView.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
                self?.reportContentHeightIfNeeded()
            }
        }
    }

    // MARK: Public

    func apply(_ sections: [any StoreSectionComponent]) {
        let identifiers = sections.enumerated().map { "\($0.offset)-\($0.element.type.rawValue)" }
        let previousSectionsByIdentifier = sectionsByIdentifier
        let previousStoreId = Self.storeId(in: self.sections)
        let currentStoreId = Self.storeId(in: sections)
        self.sections = sections
        self.identifiers = identifiers
        sectionsByIdentifier = Dictionary(uniqueKeysWithValues: zip(identifiers, sections))
        // 같은 시트를 다른 가게로 재사용하면 위치 기반 식별자가 겹쳐, 이전 가게의 광고 실패가 새 가게 광고까지 숨긴다.
        if previousStoreId != currentStoreId {
            failedAdmobIdentifiers.removeAll()
        }
        failedAdmobIdentifiers.formIntersection(identifiers)
        displayedImpressionIdentifiers.removeAll()
        expandedMenuIdentifiers.formIntersection(identifiers)
        let postCardIds = sections.compactMap { $0 as? StorePostSection }.flatMap { $0.cards.map(\.cardId) }
        expandedPostCardIds.formIntersection(postCardIds)

        let changedIdentifiers = identifiers.filter { identifier in
            guard let previous = previousSectionsByIdentifier[identifier],
                  let current = sectionsByIdentifier[identifier] else { return false }
            return AnyHashable(previous) != AnyHashable(current)
        }
        applySnapshot(reconfiguring: changedIdentifiers)
    }

    private static func storeId(in sections: [any StoreSectionComponent]) -> String? {
        sections.compactMap { $0 as? StoreScreenPreviewSection }.first?.additionalInfos.storeId
    }

    func setDisplayed() {
        guard isDisplayed.isNot else { return }
        isDisplayed = true
        let displayDependentIdentifiers = dataSource.snapshot().itemIdentifiers.filter {
            sectionsByIdentifier[$0] is StoreAdmobSection || sectionsByIdentifier[$0] is StoreThreadPostEmbedSection
        }
        if displayDependentIdentifiers.isEmpty.isNot {
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems(displayDependentIdentifiers)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
        sendVisibleImpressionLogs()
    }

    func itemIndex(where predicate: (any StoreSectionComponent) -> Bool) -> Int? {
        dataSource.snapshot().itemIdentifiers.firstIndex { identifier in
            sectionsByIdentifier[identifier].map(predicate) ?? false
        }
    }

    func sendVisibleImpressionLogs() {
        collectionView.indexPathsForVisibleItems.forEach { sendImpressionLogIfNeeded(at: $0) }
    }

    // MARK: Snapshot

    private func applySnapshot(reconfiguring changedIdentifiers: [String] = []) {
        let visibleIdentifiers = identifiers.filter { failedAdmobIdentifiers.contains($0).isNot }
        if dataSource.snapshot().itemIdentifiers != visibleIdentifiers {
            // 스티키 등록은 섹션 구성이 바뀔 때만 비운다. 같을 때 비우면 핀 된 탭 기준으로 스크롤이 튄다.
            (collectionView.collectionViewLayout as? StickySectionLayout)?.clear()
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(visibleIdentifiers)
        let reconfigured = changedIdentifiers.filter { visibleIdentifiers.contains($0) }
        if reconfigured.isEmpty.isNot {
            snapshot.reconfigureItems(reconfigured)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
        collectionView.layoutIfNeeded()
        sendVisibleImpressionLogs()
    }

    private func reconfigure(identifier: String) {
        var snapshot = dataSource.snapshot()
        guard snapshot.itemIdentifiers.contains(identifier) else { return }
        snapshot.reconfigureItems([identifier])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func hideFailedAdmob(identifier: String) {
        guard style == .preview, failedAdmobIdentifiers.insert(identifier).inserted else { return }
        applySnapshot()
    }

    private func expandMenu(identifier: String) {
        guard expandedMenuIdentifiers.insert(identifier).inserted else { return }
        reconfigure(identifier: identifier)
    }

    private func expandPost(identifier: String, cardId: String) {
        guard expandedPostCardIds.insert(cardId).inserted else { return }
        reconfigure(identifier: identifier)
    }

    private func updateThreadPostHeight(_ height: CGFloat, permalinks: [String]) {
        if let previousHeight = threadPostHeights[permalinks], abs(previousHeight - height) <= 0.5 { return }
        threadPostHeights[permalinks] = height
        let identifier = dataSource.snapshot().itemIdentifiers.first {
            (sectionsByIdentifier[$0] as? StoreThreadPostEmbedSection)?.permalinks == permalinks
        }
        guard let identifier else { return }
        reconfigure(identifier: identifier)
        sendVisibleImpressionLogs()
    }

    private func reportContentHeightIfNeeded() {
        let height = dataSource.snapshot().numberOfItems == 0 ? 0 : collectionView.contentSize.height
        if let lastReportedContentHeight, abs(lastReportedContentHeight - height) <= 0.5 { return }
        lastReportedContentHeight = height
        onContentHeightChanged?(height)
    }

    // MARK: Impression

    private func sendImpressionLogIfNeeded(at indexPath: IndexPath) {
        guard isDisplayed,
              let identifier = dataSource.itemIdentifier(for: indexPath),
              let component = sectionsByIdentifier[identifier],
              isImpressionReady(component),
              displayedImpressionIdentifiers.insert(identifier).inserted else { return }

        onImpression?(component.impressionLog)
        if let section = component as? StoreAdmobSection {
            onImpression?(section.cards.first?.impressionLog)
        }
        if let section = component as? StoreAdSection {
            onImpression?(section.cards.first?.impressionLog)
        }
    }

    private func isImpressionReady(_ component: any StoreSectionComponent) -> Bool {
        guard let section = component as? StoreThreadPostEmbedSection else { return true }
        return (threadPostHeights[section.permalinks] ?? 0) > 0
    }

    // MARK: Layout

    private static func makeLayout(style: Style) -> UICollectionViewLayout {
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

        switch style {
        case .detail:
            // 섹션 간 간격은 서버가 MARGIN 섹션으로 내려준다.
            // 네비게이션 바 높이는 호스트(바텀시트/전체화면)가 컨테이너 제약으로 확보한다.
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0)
            return StickySectionLayout(section: section)
        case .preview:
            // 미리보기 응답엔 MARGIN 섹션이 없어 섹션 간격을 레이아웃이 준다.
            section.interGroupSpacing = PreviewLayout.sectionSpacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: PreviewLayout.topInset,
                leading: 0,
                bottom: PreviewLayout.bottomInset,
                trailing: 0
            )
            return UICollectionViewCompositionalLayout(section: section)
        }
    }

    // MARK: Cell

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
        UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, identifier in
            guard let self,
                  let component = self.sectionsByIdentifier[identifier],
                  let cell = self.makeCell(for: component, identifier: identifier, indexPath: indexPath, in: collectionView) else {
                return nil
            }
            cell.contentView.backgroundColor = component.style.flatMap { UIColor(hex: $0.backgroundColor) } ?? Colors.systemWhite.color
            return cell
        }
    }

    // swiftlint:disable:next cyclomatic_complexity - 서버 섹션 타입별 셀 매핑 테이블이라 한곳에 모아 둔다
    private func makeCell(
        for component: any StoreSectionComponent,
        identifier: String,
        indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell? {
        let actionHandler: (StoreSectionAction) -> Void = { [weak self] in
            self?.onAction?($0)
        }
        if let section = component as? StoreThreadPostEmbedSection {
            return makeThreadPostCell(section, indexPath: indexPath, in: collectionView)
        }
        if let section = component as? StoreAdSection {
            return makeAdCell(section, indexPath: indexPath, in: collectionView, actionHandler: actionHandler)
        }

        switch component {
        case let section as StoreCalloutSection:
            let cell: StoreCalloutCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section); cell.onAction = actionHandler; return cell
        case let section as StoreScreenPreviewSection:
            return makePreviewCell(section, indexPath: indexPath, in: collectionView, actionHandler: actionHandler)
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
            return makeAdmobCell(section, identifier: identifier, indexPath: indexPath, in: collectionView)
        case let section as StoreTabSection:
            let cell: StoreTabCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section, selectedIndex: selectedTabIndex)
            cell.onSelectTab = { [weak self] in self?.selectedTabIndex = $0 }
            cell.onAction = actionHandler
            return cell
        case let section as StoreCouponSection:
            let cell: StoreCouponCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section); cell.onAction = actionHandler; return cell
        case let section as StoreVisitSection:
            let cell: StoreVisitCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section); cell.onAction = actionHandler; return cell
        case let section as StorePostSection:
            let cell: StorePostCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section, expandedCardIds: expandedPostCardIds)
            cell.onAction = actionHandler
            cell.onToggleBodyExpansion = { [weak self] cardId in
                self?.expandPost(identifier: identifier, cardId: cardId)
            }
            cell.onTapImage = { [weak self] images, index in self?.onTapImageGallery?(images, index) }
            return cell
        case let section as StoreImageSection:
            let cell: StoreImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section); cell.onAction = actionHandler; return cell
        case let section as StoreAppearanceDaySection:
            let cell: StoreAppearanceDayCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section); cell.onAction = actionHandler; return cell
        case let section as StoreInfoV1Section:
            let cell: StoreInfoV1Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section, isMenuExpanded: expandedMenuIdentifiers.contains(identifier))
            cell.onAction = actionHandler
            cell.onToggleMenuExpansion = { [weak self] in self?.expandMenu(identifier: identifier) }
            return cell
        case let section as StoreInfoV2Section:
            let cell: StoreInfoV2Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section, isMenuExpanded: expandedMenuIdentifiers.contains(identifier))
            cell.onAction = actionHandler
            cell.onToggleMenuExpansion = { [weak self] in self?.expandMenu(identifier: identifier) }
            cell.onTapGalleryImage = { [weak self] images, index in self?.onTapImageGallery?(images, index) }
            return cell
        case let section as StoreCTASection:
            let cell: StoreCTACell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section); cell.onAction = actionHandler; return cell
        case let section as StoreReviewSection:
            let cell: StoreReviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section)
            cell.onAction = actionHandler
            cell.onTapImage = { [weak self] images, index in self?.onTapImageGallery?(images, index) }
            return cell
        case is StoreSkeletonSection:
            let cell: StoreSkeletonCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        default:
            return nil
        }
    }

    private func makePreviewCell(
        _ section: StoreScreenPreviewSection,
        indexPath: IndexPath,
        in collectionView: UICollectionView,
        actionHandler: @escaping (StoreSectionAction) -> Void
    ) -> UICollectionViewCell {
        switch style {
        case .detail:
            let cell: StoreScreenPreviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section)
            cell.onAction = actionHandler
            cell.onTapImage = { [weak self] images, index in self?.onTapImageGallery?(images, index) }
            return cell
        case .preview:
            let cell: StorePreviewSheetCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(section, isFavorited: isFavorited)
            cell.onEvent = { [weak self] in self?.onEvent?($0) }
            return cell
        }
    }

    private func makeAdmobCell(
        _ section: StoreAdmobSection,
        identifier: String,
        indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let cell: StoreAdmobCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if let rootViewController {
            cell.bind(section, rootViewController: rootViewController, isDisplayed: isDisplayed)
        }
        cell.onClickAd = { [weak self] in
            self?.onClickAd?(section.cards.first?.clickLog)
        }
        cell.onLoadFailed = { [weak self] in
            self?.hideFailedAdmob(identifier: identifier)
        }
        return cell
    }

    private func makeAdCell(
        _ section: StoreAdSection,
        indexPath: IndexPath,
        in collectionView: UICollectionView,
        actionHandler: @escaping (StoreSectionAction) -> Void
    ) -> UICollectionViewCell {
        let cell: StoreAdCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(section)
        cell.onTap = { [weak self] card in
            if let link = card.link {
                actionHandler(.link(link, clickLog: card.clickLog))
            } else {
                self?.onClickAd?(card.clickLog)
            }
        }
        return cell
    }

    private func makeThreadPostCell(
        _ section: StoreThreadPostEmbedSection,
        indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let cell: StoreThreadPostCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let permalinks = section.permalinks
        cell.bind(section, height: threadPostHeights[permalinks], isDisplayed: isDisplayed)
        cell.onHeightSettled = { [weak self] height in
            self?.updateThreadPostHeight(height, permalinks: permalinks)
        }
        cell.onOpenURL = { [weak self] url, clickLog in
            self?.onTapThreadPostLink?(url, clickLog)
        }
        return cell
    }
}

// MARK: StorePreviewSectionsViewProtocol
extension StoreSectionsView: StorePreviewSectionsViewProtocol {
    func setFavorited(_ isFavorited: Bool) {
        guard self.isFavorited != isFavorited else { return }
        self.isFavorited = isFavorited
        // 재구성(reconfigure)하면 사진·액션바 가로 스크롤이 처음으로 돌아가므로 보이는 셀의 버튼만 갱신한다.
        collectionView.visibleCells
            .compactMap { $0 as? StorePreviewSheetCell }
            .forEach { $0.setFavorited(isFavorited) }
    }
}

// MARK: UICollectionViewDelegate
extension StoreSectionsView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll?(scrollView)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (collectionView.collectionViewLayout as? StickySectionLayout)?.registerIfNeeded(cell: cell, indexPath: indexPath)
        sendImpressionLogIfNeeded(at: indexPath)
    }
}
