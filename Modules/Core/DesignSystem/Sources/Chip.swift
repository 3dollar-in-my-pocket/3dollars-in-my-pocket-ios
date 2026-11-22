import UIKit

public final class Chip: UIView {
    public enum Style {
        case filled
        case outline
        case filter
    }

    public enum Size {
        case medium
        case small
    }

    public struct Appearance {
        public let backgroundColor: UIColor?
        public let borderColor: UIColor?
        public let borderWidth: CGFloat
        public let textColor: UIColor?

        public init(
            backgroundColor: UIColor?,
            borderColor: UIColor?,
            borderWidth: CGFloat = 1,
            textColor: UIColor?
        ) {
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.textColor = textColor
        }
    }

    public enum Layout {
        static let spacing: CGFloat = 4
        static let closeSize: CGFloat = 14
        static let font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)

        public static func size(
            style: Style,
            size: Size = .medium,
            text: String,
            showsIcon: Bool,
            showsClose: Bool = false
        ) -> CGSize {
            let metrics = Metrics(style: style, size: size)
            let textWidth = ceil((text as NSString).size(withAttributes: [.font: font]).width)
            var width = metrics.horizontalPadding * 2 + textWidth
            if showsIcon {
                width += metrics.iconSize + spacing
            }
            if showsClose {
                width += closeSize + spacing
            }
            return CGSize(width: width, height: metrics.height)
        }
    }

    struct Metrics {
        let height: CGFloat
        let horizontalPadding: CGFloat
        let iconSize: CGFloat
        let cornerRadius: CGFloat

        init(style: Style, size: Size) {
            switch (style, size) {
            case (.filled, .medium):
                self.init(height: 40, horizontalPadding: 12, iconSize: 24, cornerRadius: 20)

            case (.filled, .small):
                self.init(height: 32, horizontalPadding: 8, iconSize: 24, cornerRadius: 16)

            case (.outline, _):
                self.init(height: 36, horizontalPadding: 12, iconSize: 20, cornerRadius: 18)

            case (.filter, _):
                self.init(height: 34, horizontalPadding: 10, iconSize: 20, cornerRadius: 10)
            }
        }

        private init(height: CGFloat, horizontalPadding: CGFloat, iconSize: CGFloat, cornerRadius: CGFloat) {
            self.height = height
            self.horizontalPadding = horizontalPadding
            self.iconSize = iconSize
            self.cornerRadius = cornerRadius
        }
    }

    public let style: Style
    public let size: Size

    public var isOn: Bool = false {
        didSet {
            applyAppearance()
        }
    }

    public var customAppearance: Appearance? {
        didSet {
            applyAppearance()
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

    public var showsClose: Bool {
        get { !closeButton.isHidden }
        set { closeButton.isHidden = !newValue }
    }

    public let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    public let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(DesignSystemAsset.Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let metrics: Metrics

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
        label.font = Layout.font
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    public init(style: Style, size: Size = .medium, text: String? = nil) {
        self.style = style
        self.size = size
        self.metrics = Metrics(style: style, size: size)
        super.init(frame: .zero)

        titleLabel.text = text
        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = metrics.cornerRadius
        layer.masksToBounds = true
        addSubview(stackView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(closeButton)
        applyAppearance()
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: metrics.height),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: metrics.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -metrics.horizontalPadding),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: metrics.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: metrics.iconSize),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.closeSize),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.closeSize)
        ])
    }

    private func applyAppearance() {
        let appearance = customAppearance ?? defaultAppearance()

        backgroundColor = appearance.backgroundColor ?? .clear
        layer.borderColor = appearance.borderColor?.cgColor
        layer.borderWidth = appearance.borderColor == nil ? 0 : appearance.borderWidth
        if let textColor = appearance.textColor {
            titleLabel.textColor = textColor
            closeButton.tintColor = textColor
        }
    }

    private func defaultAppearance() -> Appearance {
        let colors = DesignSystemAsset.Colors.self

        switch (style, isOn) {
        case (.filled, false):
            return Appearance(backgroundColor: colors.gray10.color, borderColor: nil, textColor: colors.gray100.color)

        case (.filled, true):
            return Appearance(backgroundColor: colors.pink200.color, borderColor: nil, textColor: colors.mainPink.color)

        case (.outline, false):
            return Appearance(backgroundColor: colors.systemWhite.color, borderColor: colors.gray30.color, textColor: colors.gray90.color)

        case (.filter, false):
            return Appearance(backgroundColor: colors.systemWhite.color, borderColor: colors.gray30.color, textColor: colors.gray40.color)

        case (.outline, true), (.filter, true):
            return Appearance(backgroundColor: colors.pink100.color, borderColor: colors.pink500.color, textColor: colors.pink500.color)
        }
    }
}
