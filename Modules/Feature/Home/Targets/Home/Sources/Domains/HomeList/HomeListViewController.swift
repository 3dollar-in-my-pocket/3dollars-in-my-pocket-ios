import UIKit
import Combine
import CoreLocation

import Common
import DesignSystem
import Model
import Log

import SnapKit

/// 홈 바텀시트의 컨텐츠 VC. 시트 동작(드래그/스냅/스크롤 동기화) 은
/// FloatingPanelController 가 담당하고, 이 VC 는 컨텐츠와 viewModel 바인딩만 관리한다.
final class HomeListViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }

    let homeListView = HomeListView()
    private let viewModel: HomeListViewModel
    private lazy var dataSource = HomeListDataSource(
        collectionView: homeListView.collectionView,
        viewModel: viewModel,
        rootViewController: self
    )
    private lazy var curationDataSource = HomeCurationDataSource(
        collectionView: homeListView.curationView.collectionView,
        viewModel: viewModel.curationViewModel,
        rootViewController: self
    )

    var onChangeTrackingScrollView: ((UIScrollView) -> Void)?

    /// FloatingPanelController.track(scrollView:) 에 넘길 스크롤 뷰.
    var trackingScrollView: UIScrollView {
        switch viewModel.output.selectedViewType.value {
        case .curation:
            return homeListView.curationView.collectionView
        case .storeList, .unknown:
            return homeListView.collectionView
        }
    }

    init(viewModel: HomeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = homeListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = dataSource
        _ = curationDataSource
    }

    override func bindViewModelInput() {
        homeListView.mapViewButton.controlPublisher(for: .touchUpInside)
            .map { _ in () }
            .subscribe(viewModel.input.didTapMapView)
            .store(in: &cancellables)

        homeListView.tabView.didTapTab
            .subscribe(viewModel.input.didTapTab)
            .store(in: &cancellables)
    }

    override func bindViewModelOutput() {
        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, sections: [HomeListSection]) in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)

        viewModel.output.resetList
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, _) in
                owner.dataSource.reloadAdmobCards()
                owner.scrollToTop()
            }
            .store(in: &cancellables)

        bindTabOutput()
        bindCurationOutput()
    }

    private func bindTabOutput() {
        viewModel.output.tabs
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, tabs: [HomeBottomSheetTabItem]) in
                owner.homeListView.bindTabs(tabs)
            }
            .store(in: &cancellables)

        viewModel.output.selectedViewType
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, viewType: HomeBottomTabViewType) in
                owner.homeListView.showPage(viewType: viewType)
                owner.onChangeTrackingScrollView?(owner.trackingScrollView)
            }
            .store(in: &cancellables)
    }

    private func bindCurationOutput() {
        viewModel.curationViewModel.output.items
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, items: [HomeCurationSectionItem]) in
                owner.curationDataSource.reload(items)
            }
            .store(in: &cancellables)

        viewModel.curationViewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, route: HomeCurationViewModel.Route) in
                owner.handleCurationRoute(route)
            }
            .store(in: &cancellables)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeListView.updateBottomBarCoveringHeight(bottomBarCoveringHeight)
    }

    func updateMapButton(progress: CGFloat) {
        homeListView.updateMapButton(progress: progress, bottomBarCoveringHeight: bottomBarCoveringHeight)
    }

    private var bottomBarCoveringHeight: CGFloat {
        guard let tabBar = tabBarController?.tabBar, tabBar.isHidden.isNot else {
            return view.window?.safeAreaInsets.bottom ?? 0
        }
        return tabBar.frame.height
    }

    func updateTabSection(_ section: HomeBottomSheetTabSection?) {
        viewModel.input.setTabSection.send(section)
    }

    func updateCurationLocation(_ location: CLLocation) {
        viewModel.input.setCurationLocation.send(location)
    }

    func updateCards(_ cards: [any HomeListCardComponent]) {
        viewModel.input.updateCards.send(cards)
    }

    func didReplaceCards() {
        viewModel.input.didReplaceCards.send(())
    }

    private func scrollToTop() {
        let collectionView = homeListView.collectionView
        collectionView.setContentOffset(
            CGPoint(x: collectionView.contentOffset.x, y: -collectionView.adjustedContentInset.top),
            animated: false
        )
    }

    func scrollToCard(at index: Int) {
        guard homeListView.collectionView.numberOfSections > 0 else { return }
        let itemCount = homeListView.collectionView.numberOfItems(inSection: 0)
        guard itemCount > index, index >= 0 else { return }
        let indexPath = IndexPath(item: index, section: 0)
        homeListView.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}

// MARK: Route
extension HomeListViewController {
    private func handleCurationRoute(_ route: HomeCurationViewModel.Route) {
        switch route {
        case .deepLink(let link):
            Environment.appModuleInterface.deepLinkHandler.handleLinkResponse(link)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
