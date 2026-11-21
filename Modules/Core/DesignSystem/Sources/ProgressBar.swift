import UIKit

public final class ProgressBar: UIView {
    public enum Layout {
        public static let height: CGFloat = 2
    }

    public let stepCount: Int

    public private(set) var step: Int = 0

    private let fillView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var fillWidthConstraint: NSLayoutConstraint?

    public init(stepCount: Int = 4, step: Int = 0) {
        self.stepCount = max(stepCount, 1)
        super.init(frame: .zero)

        backgroundColor = DesignSystemAsset.Colors.gray30.color
        clipsToBounds = true
        addSubview(fillView)
        bindConstraints()
        setStep(step, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setStep(_ step: Int, animated: Bool) {
        self.step = min(max(step, 0), stepCount)
        fillWidthConstraint?.isActive = false
        fillWidthConstraint = fillView.widthAnchor.constraint(
            equalTo: widthAnchor,
            multiplier: CGFloat(self.step) / CGFloat(stepCount)
        )
        fillWidthConstraint?.isActive = true

        guard animated, window != nil else { return }
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            fillView.leadingAnchor.constraint(equalTo: leadingAnchor),
            fillView.topAnchor.constraint(equalTo: topAnchor),
            fillView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
