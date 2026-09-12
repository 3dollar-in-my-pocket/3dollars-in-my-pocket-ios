import UIKit

import Common
import DesignSystem
import SnapKit

/// PREVIEW 셀 아래 영역(탭·지도·수정 버튼·본문 줄)의 실루엣을 회색 블록으로 그리고 shimmer 를 흘린다.
final class StoreSkeletonCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 520
    }

    private let shimmerView = StoreSkeletonShimmerView()

    override func setup() {
        contentView.addSubview(shimmerView)
    }

    override func bindConstraints() {
        shimmerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(Layout.height)
        }
    }
}

/// shimmer 는 CoreAnimation 이 돌리므로 응답 도착 후 셀 생성으로 메인 스레드가 바쁜 동안에도 멈추지 않는다.
/// 마스크 프레임은 이 뷰 자신의 layoutSubviews 에서 잡는다. (셀 layoutSubviews 시점엔 서브뷰 제약이 아직 안 풀려 bounds 가 0)
private final class StoreSkeletonShimmerView: UIView {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let tabLabelWidth: CGFloat = 40
        static let tabLabelSpacing: CGFloat = 24
        static let tabHeight: CGFloat = 48
        static let mapHeight: CGFloat = 140
        static let mapCornerRadius: CGFloat = 20
        static let editBarHeight: CGFloat = 44
        static let editBarSpacing: CGFloat = 8
        static let lineHeight: CGFloat = 16
        static let lineSpacing: CGFloat = 12
        static let shimmerDuration: CFTimeInterval = 1.2
        static let shimmerAnimationKey = "shimmer"
    }

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = [
            Colors.gray10.color.cgColor,
            Colors.gray20.color.cgColor,
            Colors.gray10.color.cgColor
        ]
        layer.locations = [0, 0.5, 1]
        return layer
    }()

    /// 블록 실루엣. gradient 를 이 뷰로 마스킹해 블록 모양으로만 비치게 한다.
    private let blocksView = UIView()
    private let tabBlocks = (0..<3).map { _ in StoreSkeletonShimmerView.makeBlock(cornerRadius: 4) }
    private let mapBlock = StoreSkeletonShimmerView.makeBlock(cornerRadius: Layout.mapCornerRadius)
    private let editBarBlocks = (0..<2).map { _ in StoreSkeletonShimmerView.makeBlock(cornerRadius: 12) }
    private let lineBlocks = (0..<4).map { _ in StoreSkeletonShimmerView.makeBlock(cornerRadius: 4) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isUserInteractionEnabled = false
        layer.addSublayer(gradientLayer)
        (tabBlocks + [mapBlock] + editBarBlocks + lineBlocks).forEach { blocksView.addSubview($0) }
        mask = blocksView
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        blocksView.frame = bounds
        layoutBlocks()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        // 화면에서 빠졌다 돌아오면 CA 애니메이션이 제거되므로 다시 건다.
        if window != nil {
            startShimmer()
        }
    }

    private func startShimmer() {
        guard gradientLayer.animation(forKey: Layout.shimmerAnimationKey) == nil else { return }
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = Layout.shimmerDuration
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Layout.shimmerAnimationKey)
    }

    /// 실제 상세의 TAB → EDIT(지도 + 수정 버튼) → 본문 순서를 따른다.
    private func layoutBlocks() {
        let contentWidth = bounds.width - Layout.horizontalMargin * 2
        var originY: CGFloat = (Layout.tabHeight - Layout.lineHeight) / 2
        var originX = Layout.horizontalMargin

        for block in tabBlocks {
            block.frame = CGRect(x: originX, y: originY, width: Layout.tabLabelWidth, height: Layout.lineHeight)
            originX += Layout.tabLabelWidth + Layout.tabLabelSpacing
        }
        originY = Layout.tabHeight + 16

        mapBlock.frame = CGRect(x: Layout.horizontalMargin, y: originY, width: contentWidth, height: Layout.mapHeight)
        originY += Layout.mapHeight + Layout.lineSpacing

        let editBarWidth = (contentWidth - Layout.editBarSpacing) / 2
        originX = Layout.horizontalMargin
        for block in editBarBlocks {
            block.frame = CGRect(x: originX, y: originY, width: editBarWidth, height: Layout.editBarHeight)
            originX += editBarWidth + Layout.editBarSpacing
        }
        originY += Layout.editBarHeight + 32

        for (index, block) in lineBlocks.enumerated() {
            let lineWidth = index.isMultiple(of: 2) ? min(220, contentWidth) : contentWidth
            block.frame = CGRect(x: Layout.horizontalMargin, y: originY, width: lineWidth, height: Layout.lineHeight)
            originY += Layout.lineHeight + Layout.lineSpacing
        }
    }

    private static func makeBlock(cornerRadius: CGFloat) -> UIView {
        let view = UIView()
        // mask 는 알파만 쓰므로 색은 불투명이기만 하면 된다.
        view.backgroundColor = .black
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }
}
