import UIKit

import Common

final class FeedSkeletonCell: BaseCollectionViewCell {
    enum Layout {
        static let inset: CGFloat = 16
        static let spacing: CGFloat = 16
        static let badgeSize = CGSize(width: 160, height: 24)
        static let iconSize: CGFloat = 60
        static let infoLineWidths: [CGFloat] = [80, 140, 120]
        static let infoLineHeight: CGFloat = 14
        static let infoLineSpacing: CGFloat = 9
        static let bodyHeight: CGFloat = 64
        static let height: CGFloat = inset * 2 + badgeSize.height + spacing + iconSize + spacing + bodyHeight
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

    private let shimmerView = UIView()
    private let blocksView = UIView()
    private let badgeBlock = FeedSkeletonCell.makeBlock(cornerRadius: 12)
    private let iconBlock = FeedSkeletonCell.makeBlock(cornerRadius: 8)
    private let infoBlocks = Layout.infoLineWidths.map { _ in FeedSkeletonCell.makeBlock(cornerRadius: 4) }
    private let bodyBlock = FeedSkeletonCell.makeBlock(cornerRadius: 12)

    override func setup() {
        isUserInteractionEnabled = false
        contentView.backgroundColor = Colors.systemWhite.color
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = Colors.systemBlack.color.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowOffset = .zero

        shimmerView.layer.addSublayer(gradientLayer)
        shimmerView.mask = blocksView
        contentView.addSubview(shimmerView)
        ([badgeBlock, iconBlock, bodyBlock] + infoBlocks).forEach { blocksView.addSubview($0) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.frame = contentView.bounds
        gradientLayer.frame = contentView.bounds
        blocksView.frame = contentView.bounds
        layoutBlocks()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateShimmer()
    }

    private func updateShimmer() {
        guard window != nil else {
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
        let contentWidth = contentView.bounds.width - Layout.inset * 2
        var originY = Layout.inset
        badgeBlock.frame = CGRect(origin: CGPoint(x: Layout.inset, y: originY), size: Layout.badgeSize)
        originY += Layout.badgeSize.height + Layout.spacing

        iconBlock.frame = CGRect(x: Layout.inset, y: originY, width: Layout.iconSize, height: Layout.iconSize)
        var infoY = originY
        let infoX = Layout.inset + Layout.iconSize + 12
        for (block, width) in zip(infoBlocks, Layout.infoLineWidths) {
            block.frame = CGRect(x: infoX, y: infoY, width: width, height: Layout.infoLineHeight)
            infoY += Layout.infoLineHeight + Layout.infoLineSpacing
        }
        originY += Layout.iconSize + Layout.spacing

        bodyBlock.frame = CGRect(x: Layout.inset, y: originY, width: contentWidth, height: Layout.bodyHeight)
    }

    private static func makeBlock(cornerRadius: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }
}
