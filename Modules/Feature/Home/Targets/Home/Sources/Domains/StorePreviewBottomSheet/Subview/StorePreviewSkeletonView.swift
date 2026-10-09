import UIKit

import Common
import DesignSystem

final class StorePreviewSkeletonView: UIView {
    enum Layout {
        static let titleSize = CGSize(width: 140, height: 24)
        static let titleTopInset: CGFloat = 2
        static let metadataLineHeight: CGFloat = 16
        static let metadataWidths: [CGFloat] = [200, 150]
        static let metadataSpacing: CGFloat = 8
        static let actionBarTopSpacing: CGFloat = 12
        static let actionBarHeight: CGFloat = 36
        static let actionBarWidths: [CGFloat] = [104, 84, 72]
        static let actionBarSpacing: CGFloat = 8
        static let shimmerDuration: CFTimeInterval = 1.2
        static let shimmerAnimationKey = "shimmer"

        static var height: CGFloat {
            let metadataHeight = metadataLineHeight * CGFloat(metadataWidths.count)
                + metadataSpacing * CGFloat(metadataWidths.count)
            return titleTopInset + titleSize.height + metadataHeight + actionBarTopSpacing + actionBarHeight
        }
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
    private let titleBlock = StorePreviewSkeletonView.makeBlock(cornerRadius: 4)
    private let metadataBlocks = Layout.metadataWidths.map { _ in StorePreviewSkeletonView.makeBlock(cornerRadius: 4) }
    private let actionBarBlocks = Layout.actionBarWidths.map { _ in
        StorePreviewSkeletonView.makeBlock(cornerRadius: Layout.actionBarHeight / 2)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.systemWhite.color
        clipsToBounds = true
        isUserInteractionEnabled = false
        let shimmerView = UIView()
        shimmerView.layer.addSublayer(gradientLayer)
        shimmerView.mask = blocksView
        addSubview(shimmerView)
        ([titleBlock] + metadataBlocks + actionBarBlocks).forEach { blocksView.addSubview($0) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.first?.frame = bounds
        gradientLayer.frame = bounds
        blocksView.frame = bounds
        layoutBlocks()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateShimmer()
    }

    override var isHidden: Bool {
        didSet { updateShimmer() }
    }

    private func updateShimmer() {
        guard window != nil, isHidden.isNot else {
            gradientLayer.removeAnimation(forKey: Layout.shimmerAnimationKey)
            return
        }
        guard gradientLayer.animation(forKey: Layout.shimmerAnimationKey) == nil else { return }
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = Layout.shimmerDuration
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Layout.shimmerAnimationKey)
    }

    private func layoutBlocks() {
        var originY = Layout.titleTopInset
        titleBlock.frame = CGRect(origin: CGPoint(x: 0, y: originY), size: Layout.titleSize)
        originY += Layout.titleSize.height + Layout.metadataSpacing

        for (block, width) in zip(metadataBlocks, Layout.metadataWidths) {
            block.frame = CGRect(x: 0, y: originY, width: width, height: Layout.metadataLineHeight)
            originY += Layout.metadataLineHeight + Layout.metadataSpacing
        }
        originY += Layout.actionBarTopSpacing - Layout.metadataSpacing

        var originX: CGFloat = 0
        for (block, width) in zip(actionBarBlocks, Layout.actionBarWidths) {
            block.frame = CGRect(x: originX, y: originY, width: width, height: Layout.actionBarHeight)
            originX += width + Layout.actionBarSpacing
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
