import UIKit

import Common
import DesignSystem

import SnapKit

/// 바텀시트 컨텐츠 (인디케이터 + 타이틀 + 가게 리스트).
/// 흰 배경 / 둥근 코너는 FloatingPanel 의 surfaceView 가 처리하므로 여기서는 transparent 로 둔다.
final class HomeListView: BaseView {
    enum Layout {
        static let dragIndicatorTopInset: CGFloat = 8
        static let dragIndicatorSize = CGSize(width: 36, height: 4)
        static let collectionTopInset: CGFloat = 12
    }

    private let dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray30.color
        view.layer.cornerRadius = Layout.dragIndicatorSize.height / 2
        view.layer.masksToBounds = true
        return view
    }()

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

        addSubViews([
            dragIndicatorView,
            collectionView
        ])
    }

    override func bindConstraints() {
        dragIndicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(Layout.dragIndicatorTopInset)
            $0.size.equalTo(Layout.dragIndicatorSize)
        }

        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(dragIndicatorView.snp.bottom)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
}
