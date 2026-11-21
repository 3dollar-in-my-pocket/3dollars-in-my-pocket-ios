import UIKit

public final class Rating: UIView {
    public enum Style {
        case pink
        case none

        var backgroundColor: UIColor {
            switch self {
            case .pink:
                return DesignSystemAsset.Colors.pink100.color

            case .none:
                return .clear
            }
        }
    }

    public enum Layout {
        public static let size = CGSize(width: 68, height: 20)
        static let starSize: CGFloat = 12
        static let padding: CGFloat = 4
        static let maxValue = 5
    }

    public var style: Style {
        didSet {
            applyBackgroundColor()
        }
    }

    public var customBackgroundColor: UIColor? {
        didSet {
            applyBackgroundColor()
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let starImageViews: [UIImageView] = (0..<Layout.maxValue).map { _ in
        let imageView = UIImageView(image: DesignSystemAsset.Icons.starSolid.image.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = DesignSystemAsset.Colors.gray70.color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    public init(style: Style = .pink) {
        self.style = style
        super.init(frame: .zero)

        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        return Layout.size
    }

    public func bind(_ value: Int) {
        for (index, imageView) in starImageViews.enumerated() {
            imageView.tintColor = index < value
                ? DesignSystemAsset.Colors.mainPink.color
                : DesignSystemAsset.Colors.gray70.color
        }
    }

    private func applyBackgroundColor() {
        backgroundColor = customBackgroundColor ?? style.backgroundColor
    }

    private func setup() {
        applyBackgroundColor()
        layer.cornerRadius = 4
        layer.masksToBounds = true
        addSubview(stackView)
        starImageViews.forEach { stackView.addArrangedSubview($0) }
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.padding),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        starImageViews.forEach {
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: Layout.starSize),
                $0.heightAnchor.constraint(equalToConstant: Layout.starSize)
            ])
        }
    }
}
