import UIKit

import Common
import DesignSystem
import Model

import SnapKit

/// 바텀시트 컨텐츠 (인디케이터 + 타이틀 + 가게 리스트).
/// 흰 배경 / 둥근 코너는 FloatingPanel 의 surfaceView 가 처리하므로 여기서는 transparent 로 둔다.
final class HomeListView: BaseView {
    enum Layout {
        static let dragIndicatorTopInset: CGFloat = 8
        static let dragIndicatorSize = CGSize(width: 36, height: 4)
        static let collectionTopInset: CGFloat = 12

        static func mapButtonBottomInset(
            safeAreaBottom: CGFloat,
            bottomBarCoveringHeight: CGFloat
        ) -> CGFloat {
            max(safeAreaBottom, bottomBarCoveringHeight) + MapViewButton.Layout.bottomInset
        }
    }

    private let dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray30.color
        view.layer.cornerRadius = Layout.dragIndicatorSize.height / 2
        view.layer.masksToBounds = true
        return view
    }()

    let tabView = HomeBottomSheetTabView()

    private let tabContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private let pageContainerView = UIView()

    let curationView: HomeCurationView = {
        let view = HomeCurationView()
        view.isHidden = true
        return view
    }()

    let mapViewButton: MapViewButton = {
        let button = MapViewButton()
        button.alpha = 0
        button.isHidden = true
        return button
    }()

    private var bottomBarCoveringHeight: CGFloat = 0
    private var appliedMapButtonBottomInset: CGFloat = .nan
    private var mapViewButtonBottomConstraint: Constraint?

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = .init(top: Layout.collectionTopInset, left: 0, bottom: 24, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    override func setup() {
        backgroundColor = .clear

        tabContainerView.addSubview(tabView)
        pageContainerView.addSubViews([collectionView, curationView])
        contentStackView.addArrangedSubview(tabContainerView)
        contentStackView.addArrangedSubview(pageContainerView)

        addSubViews([
            dragIndicatorView,
            contentStackView,
            mapViewButton
        ])
    }

    override func bindConstraints() {
        dragIndicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(Layout.dragIndicatorTopInset)
            $0.size.equalTo(Layout.dragIndicatorSize)
        }

        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(dragIndicatorView.snp.bottom)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        tabContainerView.snp.makeConstraints {
            $0.height.equalTo(HomeBottomSheetTabView.Layout.containerHeight).priority(999)
        }

        tabView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(HomeBottomSheetTabView.Layout.topInset)
            $0.leading.trailing.equalToSuperview().inset(HomeBottomSheetTabView.Layout.horizontalInset)
        }

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        curationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        mapViewButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            mapViewButtonBottomConstraint = $0.bottom.equalToSuperview()
                .inset(MapViewButton.Layout.bottomInset).constraint
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateMapButtonBottomInset()
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updateMapButtonBottomInset()
    }

    func updateMapButton(progress: CGFloat, bottomBarCoveringHeight: CGFloat) {
        let clamped = min(max(progress, 0), 1)
        mapViewButton.alpha = clamped
        mapViewButton.isHidden = clamped <= 0
        updateBottomBarCoveringHeight(bottomBarCoveringHeight)
    }

    func bindTabs(_ tabs: [HomeBottomSheetTabItem]) {
        tabContainerView.isHidden = tabs.isEmpty
        tabView.bind(tabs)
    }

    func showPage(viewType: HomeBottomTabViewType) {
        let isCuration = viewType == .curation
        curationView.isHidden = !isCuration
        collectionView.isHidden = isCuration
    }

    func updateBottomBarCoveringHeight(_ height: CGFloat) {
        bottomBarCoveringHeight = height
        updateMapButtonBottomInset()
    }

    private func updateMapButtonBottomInset() {
        let inset = Layout.mapButtonBottomInset(
            safeAreaBottom: safeAreaInsets.bottom,
            bottomBarCoveringHeight: bottomBarCoveringHeight
        )
        guard abs(appliedMapButtonBottomInset - inset) > 0.5 || appliedMapButtonBottomInset.isNaN else { return }

        appliedMapButtonBottomInset = inset
        mapViewButtonBottomConstraint?.update(inset: inset)
        setNeedsLayout()
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
}
