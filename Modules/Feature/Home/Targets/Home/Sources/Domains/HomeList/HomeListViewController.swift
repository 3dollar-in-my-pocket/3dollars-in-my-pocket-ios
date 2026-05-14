import UIKit
import Combine

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

    /// FloatingPanelController.track(scrollView:) 에 넘길 스크롤 뷰.
    var trackingScrollView: UIScrollView {
        return homeListView.collectionView
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
    }

    override func bindViewModelOutput() {
        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { (owner: HomeListViewController, sections: [HomeListSection]) in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
    }

    func updateCards(_ cards: [any HomeListCardComponent]) {
        viewModel.input.updateCards.send(cards)
    }

    func scrollToCard(at index: Int) {
        guard homeListView.collectionView.numberOfSections > 0 else { return }
        let itemCount = homeListView.collectionView.numberOfItems(inSection: 0)
        guard itemCount > index, index >= 0 else { return }
        let indexPath = IndexPath(item: index, section: 0)
        homeListView.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}
