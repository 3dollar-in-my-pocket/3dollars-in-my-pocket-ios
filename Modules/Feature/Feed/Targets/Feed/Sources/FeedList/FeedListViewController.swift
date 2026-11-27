import UIKit
import Combine

import Common
import DesignSystem
import FeedInterface
import Model
import Log

public final class FeedListViewController: BaseViewController, LocalNewsViewControllerType {
    enum Layout {
        static let sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 24, right: 20)
        static let itemSpacing: CGFloat = 16

        static func cellWidth(in collectionView: UICollectionView) -> CGFloat {
            collectionView.bounds.width - sectionInset.left - sectionInset.right
        }
    }

    public override var screenName: ScreenName {
        viewModel.output.screenName
    }

    public var scrollView: UIScrollView {
        collectionView
    }

    public var sectionImpressionLog: AnyPublisher<SDImpressionLog, Never> {
        viewModel.output.sectionImpressionLog.eraseToAnyPublisher()
    }

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private let viewModel: FeedListViewModel
    private lazy var datasource = FeedListDatasource(collectionView: collectionView, rootViewController: self)
    private var lastLayoutWidth: CGFloat = 0
    private var cardHeightCache: [String: CGFloat] = [:]

    public init(viewModel: FeedListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupCollectionView()
        bind()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width = collectionView.bounds.width
        guard width != lastLayoutWidth else { return }
        let isFirstLayout = lastLayoutWidth == 0
        lastLayoutWidth = width
        cardHeightCache.removeAll()
        guard isFirstLayout.isNot else { return }
        collectionView.reloadData()
    }

    public override func sendPageView() { }

    public func load(newsTabId: String, mapLatitude: Double, mapLongitude: Double, maxDistanceM: Double?) {
        viewModel.input.load.send(.init(
            newsTabId: newsTabId,
            latitude: mapLatitude,
            longitude: mapLongitude,
            maxDistanceM: maxDistanceM
        ))
    }

    public func scrollToTop() {
        collectionView.setContentOffset(
            CGPoint(x: collectionView.contentOffset.x, y: -collectionView.adjustedContentInset.top),
            animated: false
        )
    }

    private func setup() {
        view.backgroundColor = .clear
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = datasource
        collectionView.delegate = self
    }

    private func bind() {
        datasource.didTapRetry
            .subscribe(viewModel.input.retry)
            .store(in: &cancellables)

        datasource.didTapImage
            .subscribe(viewModel.input.didTapImage)
            .store(in: &cancellables)

        datasource.didTapAdmob
            .subscribe(viewModel.input.didTapAdmob)
            .store(in: &cancellables)

        viewModel.output.datasource
            .main
            .withUnretained(self)
            .sink { (owner: FeedListViewController, sections: [FeedListSection]) in
                owner.datasource.reload(sections)
            }
            .store(in: &cancellables)

        viewModel.output.scrollToTop
            .main
            .withUnretained(self)
            .sink { (owner: FeedListViewController, _) in
                owner.scrollToTop()
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: FeedListViewController, route: FeedListViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = WidthAdaptiveFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Layout.itemSpacing
        layout.sectionInset = Layout.sectionInset
        return layout
    }
}

// MARK: Route
extension FeedListViewController {
    private func handleRoute(_ route: FeedListViewModel.Route) {
        switch route {
        case .deepLink(let deepLink):
            Environment.appModuleInterface.deepLinkHandler.handleLinkResponse(deepLink)
        case .presentPhotoViewer(let imageUrls, let selectedIndex):
            presentPhotoViewer(imageUrls: imageUrls, selectedIndex: selectedIndex)
        }
    }

    private func presentPhotoViewer(imageUrls: [String], selectedIndex: Int) {
        let viewController = Environment.storeInterface.getPhotoViewerViewController(
            imageUrls: imageUrls,
            selectedIndex: selectedIndex
        )
        present(viewController, animated: true)
    }
}

extension FeedListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Layout.cellWidth(in: collectionView)

        switch datasource.itemIdentifier(for: indexPath) {
        case .header(let header):
            return CGSize(width: width, height: FeedListHeaderCell.Layout.height(header: header))
        case .skeleton:
            return CGSize(width: width, height: FeedSkeletonCell.Layout.height)
        case .empty:
            return CGSize(width: width, height: FeedEmptyCell.Layout.height)
        case .error:
            return CGSize(width: width, height: FeedErrorCell.Layout.height)
        case .contentCard(let card):
            return CGSize(width: width, height: contentCardHeight(card, width: width))
        case .admobCard(let card):
            return CGSize(width: width, height: FeedAdmobCardCell.Layout.height(card))
        case .none:
            return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .contentCard(let card) = datasource.itemIdentifier(for: indexPath) else { return }
        viewModel.input.didTapCard.send(card.cardId)
    }

    private func contentCardHeight(_ card: HomeNewsContentCard, width: CGFloat) -> CGFloat {
        if let height = cardHeightCache[card.cardId] {
            return height
        }
        let height = FeedContentCardCell.Layout.height(card: card, cellWidth: width)
        cardHeightCache[card.cardId] = height
        return height
    }
}
