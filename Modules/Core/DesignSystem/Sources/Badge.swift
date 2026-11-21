import UIKit

public final class Badge: UIView {
    public enum Style {
        case pink
        case gray

        var backgroundColor: UIColor {
            switch self {
            case .pink:
                return DesignSystemAsset.Colors.pink100.color

            case .gray:
                return DesignSystemAsset.Colors.gray10.color
            }
        }

        var textColor: UIColor {
            switch self {
            case .pink:
                return DesignSystemAsset.Colors.mainPink.color

            case .gray:
                return DesignSystemAsset.Colors.gray80.color
            }
        }
    }

    public enum Layout {
        public static let height: CGFloat = 20
        static let iconSize: CGFloat = 16
        static let horizontalPadding: CGFloat = 4
        static let spacing: CGFloat = 2
    }

    public var style: Style {
        didSet {
            applyStyle()
        }
    }

    public var customBackgroundColor: UIColor? {
        didSet {
            applyStyle()
        }
    }

    public var text: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    public var attributedText: NSAttributedString? {
        get { titleLabel.attributedText }
        set { titleLabel.attributedText = newValue }
    }

    public var isIconHidden: Bool {
        get { iconView.isHidden }
        set { iconView.isHidden = newValue }
    }

    public let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 10)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    public init(style: Style, text: String? = nil) {
        self.style = style
        super.init(frame: .zero)

        titleLabel.text = text
        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
        addSubview(stackView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        applyStyle()
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalPadding),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: Layout.iconSize)
        ])
    }

    private func applyStyle() {
        backgroundColor = customBackgroundColor ?? style.backgroundColor
        titleLabel.textColor = style.textColor
    }
}
