import UIKit

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
    private var isVisibleInTab = false

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
        guard isFirstLayout.isNot else { return }
        collectionView.reloadData()
    }

    public override func sendPageView() {
        guard isVisibleInTab else { return }
        super.sendPageView()
    }

    public func load(mapLatitude: Double, mapLongitude: Double, maxDistanceM: Double?) {
        viewModel.input.load.send(.init(latitude: mapLatitude, longitude: mapLongitude, maxDistanceM: maxDistanceM))
    }

    public func setVisible(_ isVisible: Bool) {
        guard isVisibleInTab != isVisible else { return }
        isVisibleInTab = isVisible
        if isVisible {
            sendPageView()
        }
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
        }
    }
}

extension FeedListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Layout.cellWidth(in: collectionView)

        switch datasource.itemIdentifier(for: indexPath) {
        case .header:
            return CGSize(width: width, height: FeedListHeaderCell.Layout.height)
        case .advertisement:
            return CGSize(width: width, height: FeedAdvertisementCell.Layout.height)
        case .skeleton:
            return CGSize(width: width, height: FeedSkeletonCell.Layout.height)
        case .empty:
            return CGSize(width: width, height: FeedEmptyCell.Layout.height)
        case .error:
            return CGSize(width: width, height: FeedErrorCell.Layout.height)
        case .feed(let feed):
            return CGSize(width: width, height: FeedCell.Layout.calculateHeight(feed: feed, cellWidth: width))
        case .none:
            return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .feed(let feed) = datasource.itemIdentifier(for: indexPath) else { return }
        viewModel.input.didTapFeed.send(feed)
    }
}
