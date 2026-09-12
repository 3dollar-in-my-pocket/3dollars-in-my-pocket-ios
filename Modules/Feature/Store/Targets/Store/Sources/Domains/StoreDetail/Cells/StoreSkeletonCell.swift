import UIKit

import Common
import DesignSystem
import SnapKit

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
        view.backgroundColor = .black
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }
}
