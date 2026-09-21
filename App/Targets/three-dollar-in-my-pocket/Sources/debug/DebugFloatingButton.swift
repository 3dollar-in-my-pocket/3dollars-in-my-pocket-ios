import UIKit

import Common
import DesignSystem

/// 개발 환경에서 앱 전역에 떠 있는 디버깅 진입 버튼.
/// 드래그로 위치를 옮길 수 있고, 탭하면 디버깅 메뉴 바텀시트를 연다.
final class DebugFloatingButton: UIView {
    enum Layout {
        static let size: CGFloat = 48
        /// 화면 가장자리에서 최소한 띄울 여백.
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

    /// 드래그 시작 시점의 중심. 팬 제스처의 누적 translation 과 합쳐 위치를 계산한다.
    private var panStartCenter: CGPoint = .zero

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Layout.size, height: Layout.size))
        setupViews()
        setupGestures()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

    /// 버튼이 화면(세이프 에어리어) 밖으로 나가 다시 못 잡는 상황을 막는다.
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

    /// 저장된 위치가 있으면 복원하고, 없으면 우측 하단 기본 위치에 놓는다.
    func applyInitialPosition(in superview: UIView) {
        let insets = superview.safeAreaInsets
        let defaultCenter = CGPoint(
            x: superview.bounds.width - insets.right - Layout.size / 2 - 16,
            y: superview.bounds.height - insets.bottom - Layout.size / 2 - 120
        )
        center = clamped(Preference.shared.debugFloatingButtonCenter ?? defaultCenter, in: superview)
    }
}
