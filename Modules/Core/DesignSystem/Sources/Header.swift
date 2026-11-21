import UIKit

public final class Header: UIView {
    enum Layout {
        static let insets = UIEdgeInsets(top: 20, left: 20, bottom: 16, right: 20)
        static let titleSpacing: CGFloat = 4
        static let descriptionSpacing: CGFloat = 8
        static let titleLineHeight: CGFloat = 32
        static let subtitleLineHeight: CGFloat = 24
    }

    public var title: String? {
        get { titleLabel.attributedText?.string }
        set {
            titleLabel.attributedText = newValue.map {
                NSAttributedString(string: $0, attributes: Self.titleAttributes)
            }
        }
    }

    public var subtitle: String? {
        get { subtitleLabel.attributedText?.string }
        set {
            setSubtitle(newValue.map { NSAttributedString(string: $0, attributes: Self.subtitleAttributes) })
        }
    }

    public var descriptionText: String? {
        get { descriptionLabel.text }
        set {
            descriptionLabel.text = newValue
            descriptionLabel.isHidden = newValue?.isEmpty ?? true
        }
    }

    public static let subtitleAttributes: [NSAttributedString.Key: Any] = attributes(
        font: DesignSystemFontFamily.Pretendard.bold.font(size: 16),
        color: DesignSystemAsset.Colors.gray40.color,
        lineHeight: Layout.subtitleLineHeight
    )

    private static let titleAttributes: [NSAttributedString.Key: Any] = attributes(
        font: DesignSystemFontFamily.Pretendard.bold.font(size: 24),
        color: DesignSystemAsset.Colors.gray100.color,
        lineHeight: Layout.titleLineHeight
    )

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.isHidden = true
        return label
    }()

    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.titleSpacing
        return stackView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.textColor = DesignSystemAsset.Colors.gray80.color
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Layout.descriptionSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public init(title: String? = nil, subtitle: String? = nil, descriptionText: String? = nil) {
        super.init(frame: .zero)

        setup()
        bindConstraints()
        self.title = title
        self.subtitle = subtitle
        self.descriptionText = descriptionText
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setSubtitle(_ attributedText: NSAttributedString?) {
        subtitleLabel.attributedText = attributedText
        subtitleLabel.isHidden = (attributedText?.length ?? 0) == 0
    }

    private func setup() {
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(titleStackView)
        stackView.addArrangedSubview(descriptionLabel)
        addSubview(stackView)
    }

    private func bindConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.insets.top),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.insets.left),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.insets.right),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.insets.bottom),
            titleStackView.trailingAnchor.constraint(lessThanOrEqualTo: stackView.trailingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }

    private static func attributes(
        font: UIFont,
        color: UIColor,
        lineHeight: CGFloat
    ) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        return [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: (lineHeight - font.lineHeight) / 4
        ]
    }
}
