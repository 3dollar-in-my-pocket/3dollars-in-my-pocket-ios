import UIKit

import DesignSystem

/// 미리보기를 full 로 끌어올린 직후 상세 응답을 기다리는 동안 보여주는 플레이스홀더.
/// 상세 첫 화면(헤더·액션바·사진·탭·지도) 실루엣만 회색 블록으로 그리고 shimmer 를 흘린다.
/// shimmer 는 CoreAnimation 이 돌리므로 상세 첫 렌더로 메인 스레드가 바쁜 동안에도 멈추지 않는다.
final class StoreDetailSkeletonView: UIView {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let listMargin: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let pillHeight: CGFloat = 36
        static let pillWidths: [CGFloat] = [88, 72, 96]
        static let pillSpacing: CGFloat = 4
        static let imageSize: CGFloat = 120
        static let imageSpacing: CGFloat = 8
        static let mapHeight: CGFloat = 140
        static let mapCornerRadius: CGFloat = 20
        static let lineHeight: CGFloat = 16
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

    /// 블록 실루엣. 이 뷰를 mask 로 써서 gradient 가 블록 모양으로만 비친다.
    private let blocksView = UIView()
    private let titleBlock = StoreDetailSkeletonView.makeBlock()
    private let primaryMetadataBlock = StoreDetailSkeletonView.makeBlock()
    private let secondaryMetadataBlock = StoreDetailSkeletonView.makeBlock()
    private let pillBlocks = Layout.pillWidths.map { _ in
        StoreDetailSkeletonView.makeBlock(cornerRadius: Layout.pillHeight / 2)
    }
    private let imageBlocks = (0..<3).map { _ in StoreDetailSkeletonView.makeBlock(cornerRadius: 12) }
    private let tabBlocks = (0..<3).map { _ in StoreDetailSkeletonView.makeBlock(cornerRadius: 4) }
    private let mapBlock = StoreDetailSkeletonView.makeBlock(cornerRadius: Layout.mapCornerRadius)
    private let lineBlocks = (0..<3).map { _ in StoreDetailSkeletonView.makeBlock(cornerRadius: 4) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.systemWhite.color
        isUserInteractionEnabled = false
        clipsToBounds = true
        layer.addSublayer(gradientLayer)

        let blocks = [titleBlock, primaryMetadataBlock, secondaryMetadataBlock]
            + pillBlocks + imageBlocks + tabBlocks + [mapBlock] + lineBlocks
        blocks.forEach { blocksView.addSubview($0) }
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
        if window != nil, isHidden.isNot {
            startAnimating()
        }
    }

    func startAnimating() {
        guard gradientLayer.animation(forKey: Layout.shimmerAnimationKey) == nil else { return }
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = Layout.shimmerDuration
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Layout.shimmerAnimationKey)
    }

    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: Layout.shimmerAnimationKey)
    }

    /// 상세 첫 화면(StoreScreenPreviewCell → 탭 → EDIT 지도)의 세로 배치를 그대로 따른다.
    private func layoutBlocks() {
        let width = bounds.width
        let contentWidth = width - Layout.horizontalMargin * 2
        var originY: CGFloat = 20

        titleBlock.frame = CGRect(x: Layout.horizontalMargin, y: originY, width: min(180, contentWidth), height: 24)
        originY += 24 + 8
        primaryMetadataBlock.frame = CGRect(
            x: Layout.horizontalMargin, y: originY, width: min(120, contentWidth), height: 14
        )
        originY += 14 + 6
        secondaryMetadataBlock.frame = CGRect(
            x: Layout.horizontalMargin, y: originY, width: min(200, contentWidth), height: 14
        )
        originY += 14 + 16

        var originX = Layout.listMargin
        for (block, pillWidth) in zip(pillBlocks, Layout.pillWidths) {
            block.frame = CGRect(x: originX, y: originY, width: pillWidth, height: Layout.pillHeight)
            originX += pillWidth + Layout.pillSpacing
        }
        originY += Layout.pillHeight + 16

        originX = Layout.listMargin
        for block in imageBlocks {
            block.frame = CGRect(x: originX, y: originY, width: Layout.imageSize, height: Layout.imageSize)
            originX += Layout.imageSize + Layout.imageSpacing
        }
        originY += Layout.imageSize + 24

        originX = Layout.horizontalMargin
        for block in tabBlocks {
            block.frame = CGRect(x: originX, y: originY, width: 40, height: Layout.lineHeight)
            originX += 40 + 24
        }
        originY += Layout.lineHeight + 24

        mapBlock.frame = CGRect(x: Layout.horizontalMargin, y: originY, width: contentWidth, height: Layout.mapHeight)
        originY += Layout.mapHeight + 20

        for (index, block) in lineBlocks.enumerated() {
            let lineWidth = index == lineBlocks.count - 1 ? contentWidth : min(CGFloat(240 - index * 80), contentWidth)
            block.frame = CGRect(x: Layout.horizontalMargin, y: originY, width: lineWidth, height: Layout.lineHeight)
            originY += Layout.lineHeight + 12
        }
    }

    private static func makeBlock(cornerRadius: CGFloat = Layout.cornerRadius) -> UIView {
        let view = UIView()
        // mask 는 알파만 쓰므로 색은 불투명이기만 하면 된다.
        view.backgroundColor = .black
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }
}
