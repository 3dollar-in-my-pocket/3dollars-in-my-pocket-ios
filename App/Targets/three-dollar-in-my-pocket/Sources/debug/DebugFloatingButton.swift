import UIKit

import Common
import DesignSystem

final class DebugFloatingButton: UIView {
    enum Layout {
        static let size: CGFloat = 48
        static let edgeInset: CGFloat = 8
    }

    var onTap: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "DEV"
        label.textColor = .white
        label.font = Fonts.bold.font(size: 12)
        label.textAlignment = .center
        return label
    }()

    private var panStartCenter: CGPoint = .zero

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Layout.size, height: Layout.size))
        setupViews()
        setupGestures()
    }

    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = Colors.gray100.color.withAlphaComponent(0.85)
        layer.cornerRadius = Layout.size / 2
        layer.borderWidth = 2
        layer.borderColor = Colors.mainPink.color.cgColor
        addSubview(titleLabel)
        titleLabel.frame = bounds
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
    }

    @objc private func didTap() {
        onTap?()
    }

    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        guard let superview else { return }

        switch gesture.state {
        case .began:
            panStartCenter = center
        case .changed, .ended:
            let translation = gesture.translation(in: superview)
            center = clamped(
                CGPoint(x: panStartCenter.x + translation.x, y: panStartCenter.y + translation.y),
                in: superview
            )
            if gesture.state == .ended {
                Preference.shared.debugFloatingButtonCenter = center
            }
        default:
            break
        }
    }

    private func clamped(_ point: CGPoint, in superview: UIView) -> CGPoint {
        let insets = superview.safeAreaInsets
        let half = Layout.size / 2
        let minX = insets.left + half + Layout.edgeInset
        let maxX = superview.bounds.width - insets.right - half - Layout.edgeInset
        let minY = insets.top + half + Layout.edgeInset
        let maxY = superview.bounds.height - insets.bottom - half - Layout.edgeInset

        return CGPoint(
            x: min(max(point.x, minX), max(minX, maxX)),
            y: min(max(point.y, minY), max(minY, maxY))
        )
    }

    func applyInitialPosition(in superview: UIView) {
        let insets = superview.safeAreaInsets
        let defaultCenter = CGPoint(
            x: superview.bounds.width - insets.right - Layout.size / 2 - 16,
            y: superview.bounds.height - insets.bottom - Layout.size / 2 - 120
        )
        center = clamped(Preference.shared.debugFloatingButtonCenter ?? defaultCenter, in: superview)
    }
}
